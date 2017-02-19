module DTK
  module Puppet
    class PuppetStructure < Hash
      require_relative('pp_file')

      def initialize(files, module_name)
        @pp_files    = files
        @module_name = module_name
        self['component_defs'] = {}
      end

      def parse_pp_files
        @pp_files.each do |pp_file|
          if child = PPFile.new(pp_file, @module_name).process_pp_file
            self['component_defs'].merge!(child)
          end
        end
        self
      end
    end
  end
end