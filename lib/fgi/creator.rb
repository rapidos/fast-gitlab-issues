module Fgi
  class Creator
    class << self

      # @param configuration [Hash] the configuration Hash to write in a persistent file
      def configuration_file(configuration)
        # @see Fgi::Config.load
        # configuration already contain :
        #   url
        #   project_gitlab_id
        #   project_namespaced
        #   projects_url
        configuration = configuration.merge(
          # Add 'title=' and 'description=' in request body
          issues_url: "#{configuration[:projects_url]}/#{configuration[:project_gitlab_id]}/issues"
          # Here add the used GitLab API urls
        )
        File.open('.fast_gitlab_issues.yml', 'w') { |f| f.write configuration.to_yaml }
      end

    end
  end
end
