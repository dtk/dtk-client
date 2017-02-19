module DTK
  module Puppet
    class PPFile < Hash
      require_relative('pp_file')

      def initialize(pp_file, module_name)
        @pp_file     = pp_file
        @module_name = module_name
        @pp_dump     = nil
      end

      def process_pp_file
        if @pp_dump = `puppet parser dump "#{@pp_file}"`
          parse_pp_file
        end
      end

      private

      def parse_pp_file
        cmp_hash = {}

        @pp_dump.slice!("--- #{@pp_file}")
        first_line = @pp_dump.lines.first

        name = nil
        type = nil

        if pp_class = ret_puppet_class?(first_line)
          name = pp_class.gsub("#{@module_name}::", '')
          type = 'class'
          first_line.slice!("(class #{pp_class}")
        elsif pp_def = ret_puppet_definition?(first_line)
          name = pp_def.gsub("#{@module_name}::", '')
          type = 'definition'
          first_line.slice!("(define #{pp_def}")
        else
          return
        end

        attributes = ret_attributes(first_line)
        cmp_hash['attributes'] = attributes unless attributes.empty?

        if type.eql?('definition')
          cmp_hash['actions'] = { 'create' => { 'puppet_definition' => pp_def } }
        else
          cmp_hash['actions'] = { 'create' => { 'puppet_class' => pp_class } }
        end

        { name.gsub("::", '_') => cmp_hash }
      end

      def ret_puppet_definition?(line)
        (line.match(/^(\(define)(\s)([^\s]+)(\s)/)||[])[3]
      end

      def ret_puppet_class?(line)
        (line.match(/^(\(class)(\s)([^\s]+)(\s)/)||[])[3]
      end

      def ret_attributes(line)
        attributes = {}
        line.strip!

        if matching = line.match(/(\(parameters)(.+)\)/)
          if params = matching[2]
            # defined_params = params.scan(/\(=\s*([^\s]*)\s*([^\s|\)]*)\)/)
            defined_params = params.scan(/\(=\s*([^\s]*)\s*([^\s]*)\)/)
            defined_params.each do |defined|
              name, type = defined
              attributes.merge!(name => type_hash(type))
            end

            undef_params_flatten = params.scan(/\s*([^\s]*)\s*/).flatten
            undef_params_flatten.reject! { |un| un.include?('(') || un.include?(')') || un.eql?('') }

            undefined_params = undef_params_flatten - defined_params.flatten

            undefined_params.each do |undef_param|
              attributes.merge!(undef_param => { 'required' => true, 'type' => 'string'})
            end
          end
        end

        attributes
      end

      def type_hash(type)
        case type
        when 'true' || 'false'
          {:type => 'boolean'}
        when '({})'
          {:type => 'hash'}
        when '([])'
          {:type => 'array'}
        else
          {:type => 'string'}
        end
      end

    end
  end
end
