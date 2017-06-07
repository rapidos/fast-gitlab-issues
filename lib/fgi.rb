#!/usr/bin/env ruby

require 'yaml'
require 'json'

module Fgi
  require_relative 'fgi/config'
  require_relative 'fgi/version'
  require_relative 'fgi/gitlab_request'
  require_relative 'fgi/helper'
  require_relative 'fgi/configurator'
  require_relative 'fgi/generate_file'
  require_relative 'fgi/creator'

  CONFIG_FILE = '.fast_gitlab_issues.yml'
  TOKEN_FILE =  '.gitlab_access_token'

  # Set constant CONFIG to access it easily
  if File.exists?(CONFIG_FILE)
    config = File.expand_path(CONFIG_FILE)
    CONFIG = YAML.load_file(config)
  end

  # Set constant TOKEN to access it easily
  if File.exists?(TOKEN_FILE)
    TOKEN = File.open('.gitlab_access_token', 'rb').read
  end

  class << self
  end
end
