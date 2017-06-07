module Fgi
  class Config
    class << self
      def load(source)
        @config = {
          url: nil,
          project_gitlab_id: nil,
          project_namespaced: nil,
          projects_url: nil,
        }

        Fgi::GenerateFile.new(@config) if !File.exist?(source)
        Fgi::GenerateFile.token if !File.exist?('.gitlab_access_token')

        config = YAML.load_file(source)
        token = File.open(".gitlab_access_token", "rb").read
        @config.merge! config if config
        @config[:token] = token
      end

      def include?(key)
        @config.include?(key)
      end

      def [](key)
        @config[key]
      end

      def to_yaml
        @config.to_yaml
      end

      def current
        @config ||= {
          url: nil,
          project_gitlab_id: nil,
          project_namespaced: nil,
          projects_url: nil
        }
      end
    end
  end
end
