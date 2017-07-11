module Fgi
  class GitlabRequest
    class << self

      # Generic method to POST requests
      # @param uri [URI] the given GitLab API URI for POST request
      # @param headers [Hash] the headers to set for the request
      # @param body [Hash] the body to set for the request
      # @return [String] the received response from GitLab
      def post(uri:, headers: nil, body: nil)
        req = Net::HTTP::Post.new(uri)
        # Set headers if given
        headers.each { |k, v| req[k] = v } unless headers.nil?
        # Set body if given
        req.body = body.to_json unless body.nil?
        # Requested headers to authenticate
        req['PRIVATE-TOKEN'] = TOKEN

        res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https', debug_output: $stdout) do |http|
          http.set_debug_output($stdout)
          JSON.parse(http.request(req).body)
        end

        res
      end

      # Try to create a new issue on GitLab then display the result message
      # @param title [String] the inline given title for the new issue
      def post_issue(title)
        puts "\nWrite your issue description right bellow (save and quit with CTRL+D) :"
        puts "---------------------------------------------------------------------\n\n"

        begin
          description = STDIN.read
        rescue Interrupt => int
          puts %q[Why did you killed me ? :'(]
          exit!
        end

        uri = URI.parse("#{CONFIG[:issues_url]}")
        headers = {'Content-Type': 'application/json'}
        body = {title: title, description: description}

        response = post(uri: uri, headers: headers, body: body)

        post_issue_display(response)
      end


      private

      def post_issue_display(response)
        if !response['iid'].nil?
          puts "
Your issue has been successfully created.
To view it, please follow the link bellow :

#{CONFIG[:url]}/#{CONFIG[:project_namespaced]}/issues/#{response['iid'].to_s}

Thank you for using Fast Gitlab Issues!"
        else
          puts %q"
I'm not really sure what happened, but I believe something went wrong.
puts CALL HELP!!!
          "
        end
      end
    end
  end
end
