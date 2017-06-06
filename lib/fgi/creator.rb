module Fgi
  class Creator
    class << self

      # Get the issue's description and initiate its creation
      # @param title [String] the issue's title
      def issue(title)
        puts "\nWrite your issue description right bellow (save and quit with CTRL+D) :"
        puts "---------------------------------------------------------------------\n\n"
        begin
          description = STDIN.read
        rescue Interrupt => int
          puts %q[Why did you killed me ? :'(]
          exit!
        end
        Fgi::Executor.new.process_data(title, description)
      end

      # @param configuration [Hash] the configuration Hash to write in a persistent file
      def configuration_file(configuration)
        source_url = configuration[:url]
        configuration = configuration.merge(
          get_projects_path: "#{source_url}/api/v4/projects",
          search_projects_path: "#{source_url}/api/v4/projects?search=",
          post_issue_url: "#{source_url}/api/v4/projects/#{configuration[:project_gitlab_id]}/issues?"
        )
        File.open('.fast_gitlab_issues.yml', 'w') { |f| f.write configuration.to_yaml }
      end

    end
  end
end
