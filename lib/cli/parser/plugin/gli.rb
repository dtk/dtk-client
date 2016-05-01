require 'gli'
module DTK::CLI
  class Parser
    module Plugin
      class Gli
        include ::GLI::App

        def assert_defaults
          program_desc 'DTK CLI tool'
          version ::DTK::CLI::VERSION
          subcommand_option_handling :normal
          arguments :strict
        end
      end
    end
  end
end
