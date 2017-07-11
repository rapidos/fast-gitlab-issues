module Fgi
  class Configurator
    class << self

      def run
        @config = Fgi::Config.current
        is_git_dir?
        puts '####################################################################'
        puts '            Welcome to Fast Gitlab Issues configuration             '
        puts "####################################################################\n\n"
        puts "#### Enter 'quit' or 'exit' at any time to go back to buisness! ####\n\n"

        puts 'Please enter your Gitlab Url:'
        validate_and_save_gitlab_uri

        puts "\nPlease enter your Gitlab access token :"
        puts "(You can generate new token from Gitlab -> Settings -> Access Tokens)"
        puts '---------------------------------------'
        validate_and_save_gitlab_token

        puts "\nPlease enter the name of the current project :"
        puts '----------------------------------------------'
        search_and_save_project

        Fgi::Creator.configuration_file(@config)

        puts "\nYou are now set to work on #{@config[:project_namespaced]}."
        puts 'Your configuration has been saved to .fast_gitlab_issues.yml, enjoy !'
        puts "\n####################################################################"
      end

      # Check the token validity then call the function that save it.
      # Recursive if the token is invalid.
      # @param inline_token [String] the given token through `$ fgi --token <token>`
      def validate_and_save_gitlab_token(inline_token = nil)
        begin
          @token = if inline_token.nil?
                     STDIN.gets.chomp
                   else
                     @config = CONFIG # Dirty stuff
                     @uri = URI.parse(@config[:url])
                     inline_token
                   end
          if %w(quit exit).include?(@token)
            puts 'See you back soon !'
            exit!
          end
        rescue NameError => ne
          puts %q"You didn't configure FGI. Try : fgi --config"
        rescue Interrupt => int
          puts %q"Why did you killed me ? :'("
          exit!
        end
        @config[:projects_url] = "#{@config[:url]}/api/v4/projects"

        req = Net::HTTP::Get.new(@config[:projects_url])
        req['PRIVATE-TOKEN'] = @token
        res = Net::HTTP.start(@uri.hostname, @uri.port) { |http| http.request(req) }

        if res.code == '200'
          save_gitlab_token
        else
          puts "\nOops, seems to be an invalid token. Try again or quit (quit/exit) :"
          puts '--------------------------------------------------------------'
          validate_and_save_gitlab_token
        end
      end

      private

      # Check the GitLab url validity and save it in a configuration file.
      # Recursive if the GitLab url is invalid.
      def validate_and_save_gitlab_uri
        puts 'example: http://gitlab.example.com/'
        puts '-----------------------------------'
        begin
          input = STDIN.gets.chomp
          if %w(quit exit).include?(input)
            puts 'See you back soon !'
            exit!
          end
          input = "http://#{input}" if !input.start_with?('http://', 'https://')
          @uri = URI.parse("#{input}/")
          @config[:url] = "#{@uri.scheme}://#{@uri.host}"
          req = Net::HTTP.new(@uri.host, @uri.port)
          res = req.request_head(@uri.path)
        rescue Interrupt => int
          puts %q[Why did you killed me ? :'(]
          exit!
        rescue Exception => e
          puts "\nOops, seems to be a bad url. Try again or quit (quit/exit) :"
          validate_and_save_gitlab_uri
        end
      end

      # Write the token in a local file and add it to the .gitignore.
      def save_gitlab_token
        File.open('.gitlab_access_token', 'w') { |f| f.write @token }
        if File.open('.gitignore').grep(/.gitlab_access_token/).empty?
          open('.gitignore', 'a') do |f|
            f.puts ''
            f.puts %q(# FGI GitLab's secret token)
            f.puts '.gitlab_access_token'
          end
        end
        puts "\nGitlab secret token successfully saved to file and added to .gitignore."
      end

      # Check for projects titles containing the given keyword then call
      #   the function that allow to select the right one and save it.
      # Recursive if the given keyword don't match anything.
      def search_and_save_project
        begin
          project_name = STDIN.gets.chomp
          if %w(quit exit).include?(project_name)
            puts 'See you back soon !'
            exit!
          end
        rescue Interrupt => int
          puts %q[Why did you killed me ? :'(]
          exit!
        end

        req = Net::HTTP::Get.new("#{@config[:projects_url]}?search=#{project_name}")
        req['PRIVATE-TOKEN'] = @token
        res = Net::HTTP.start(@uri.hostname, @uri.port) { |http| http.request(req) }

        results = JSON.parse(res.body)
        if res.code == '200' && !results.empty?
          puts "\nFound #{results.count} match(es):"
          results.each_with_index do |result, i|
            puts "#{i+1} - #{result['name_with_namespace']}"
          end
          validate_option(results)
        else
          puts "\nOops, we couldn't find a project called #{project_name}. Try again or quit (quit/exit) :"
          puts '-------------------------------------------------------------------'+('-'*project_name.length) # Yes, i'm a perfectionist <3
          search_and_save_project
        end
      end

      # Ask the user to select a project then save its id and full name in a configuration file.
      # Recursive if the given number don't match any displayed project.
      # @param results [Hash] the hash containing the found projects informations
      def validate_option(results)
        puts "\nPlease insert the number of the current project :"
        puts '-------------------------------------------------'
        begin
          option = STDIN.gets.chomp.to_i
        rescue Interrupt => int
          puts %q[Why did you killed me ? :'(]
          exit!
        end
        if (1..results.length+1).include?(option)
          @config[:project_gitlab_id] = results[option - 1]['id']
          @config[:project_namespaced] = results[option - 1]['path_with_namespace']
        else
          puts "\nSorry, the option is out of range. Try again :"
          validate_option(results)
        end
      end

      # In case the user used `$ fgi --token <token>`, initialize some needed variables.
      def set_config
        config_file = File.expand_path(CONFIG_FILE)
        @config = YAML.load_file(config_file)
        @uri = URI.parse(@config[:url])
      end

      # Check if the current directory is a git one.
      # @return [Boolean] true if the current directory is a git one, false otherwise
      def is_git_dir?
        is_git_directory = Dir.exists?('.git')
        if !is_git_directory
          puts %q(This doesn't seem to be the root of a git repository, browse to the root of your project and try again.)
        end
        return is_git_directory
      end
    end
  end
end
