module Fgi
  class Configurator
    class << self
      def run
        @config = Fgi::Config.current
        not_git_directory = !File.exist?(File.expand_path('.gitignore'))
        puts "This doesn't seem to be the root of a git repository, browse to the root of your project and try again." if not_git_directory
        return if not_git_directory
        puts ''
        puts '####################################################################'
        puts '            Welcome to Fast Gitlab Issues configuration             '
        puts '####################################################################'
        puts ''
        puts "Please enter your Gitlab access token:"
        validate_and_save_gitlab_token
        puts "Please paste the project url:"
        get_id_from_gitlab
        File.open('.fast_gitlab_issues.yml', 'w') {|f| f.write @config.to_yaml }
        puts "You are now set to work on #{@config[:project_namespaced]}."
        puts "Your configuration has been saved to .fast_gitlab_issues.yml, enjoy!"
        puts ''
        puts '####################################################################'
      end

      def get_id_from_gitlab
        puts 'example: http://YOUR_GITLAB_URL/modulotech/fast-gitlab-issues'
        @uri = URI.parse(STDIN.gets.chomp)
        @config[:url] = "#{@uri.scheme}://#{@uri.host}"
        uri = URI.parse("#{@config[:url]}/api/v4/projects?search=#{@uri.path.split('/').last}")
        Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
          req = Net::HTTP::Get.new uri
          req['Authorization'] = "Bearer #{@token}"
          @response = JSON.parse(http.request(req).body)
        end
        if !@response[0].nil?
          puts "Found #{@response.count} match(es):"
          @response.each_with_index do |response, i|
            puts "#{i+1} - #{response['name_with_namespace']}"
          end
          puts "Please insert the number of the current project:"
          @option = STDIN.gets.chomp.to_i
          validate_option
        else
          puts "We couldn't find a project called #{@uri.path.split('/').last}, can you please double check that url?"
          get_id_from_gitlab
        end
      end

      def validate_option
        if (1..@response.length+1).include?(@option)
          @config[:project_gitlab_id] = @response[@option - 1]["id"]
          @config[:project_namespaced] = @response[@option - 1]["path_with_namespace"]
        else
          puts "Sorry, the option is out of range, try again:"
          @option = STDIN.gets.chomp.to_i
          validate_option
        end
      end

      def validate_and_save_gitlab_token
        @token = STDIN.gets.chomp
        if @token.length > 30
          save_gitlab_token(@token)
        else
          puts "That doesn't seem to be a valid token, can you please check again?"
          validate_and_save_gitlab_token
        end
      end

      def save_gitlab_token(token)
        @token = token
        File.open('.gitlab_access_token', 'w') {|f| f.write @token }
        if File.open('.gitignore').grep(/.gitlab_access_token/).empty?
          open('.gitignore', 'a') do |f|
            f.puts ''
            f.puts "# Gfi secret token for gitlab"
            f.puts ".gitlab_access_token"
          end
        end
        puts "Gitlab secret token successfully saved to file and added to .gitignore."
      end
    end
  end
end
