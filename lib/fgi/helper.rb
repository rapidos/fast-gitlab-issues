module Fgi
  class Helper
    class << self
      def run
        puts '
Welcome to Fast Gitlab Issues!

The following commands are currently supported:

fgi <title>         # initiates the process to create a gitlab issue
fgi --help          # opens this help menu
fgi --config        # starts the configuration wizard
fgi --token <token> # saves the private gitlab token to a file and adds it to .gitignore

The config will ask you for your gitlab access token (you can get it from AF2) and the project URL from gitlab.

To create a gitlab issue just type:

$ fgi My awesome title goes here

Vim will open so you can write a description, and upon closing, it will be pushed to gitlab.
A success message should then appear.
        '
      end
    end
  end
end
