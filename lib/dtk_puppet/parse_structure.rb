 module DTK::Puppet
  class ParseStructure < Hash
    def initialize(ast_item = nil, _opts = {})
      return super() if ast_item.nil?
    end

    #### used in generate_meta
    def config_agent_type
      :puppet
    end

    def render_hash_form(module_name)
      rendered_hash = {}

      self[:children].each do |child|
        name       = child['name'].gsub("#{module_name}::", '')
        type       = child['type']
        type_name  = child['name']
        attributes = nil

        attributes = process_attributes(child['attributes']) if child['attributes']
        actions    = calculate_action(type, type_name)

        child_name = name.gsub('::', '_')
        child_hash = { child_name => {} }

        child_hash[child_name].merge!('attributes' => attributes) if attributes
        child_hash[child_name].merge!('actions' => actions)

        rendered_hash.merge!(child_hash)
      end

      rendered_hash
    end

    def process_attributes(attributes)
      processed_atttibutes = {}
      attributes.each do |attr|
        attr_name = attr['name']
        attr_type = attr['type']
        attr_hash = { attr_name => { 'type' => attr_type } }

        if required = attr['required']
          attr_hash[attr_name].merge!('required' => required)
        end

        processed_atttibutes.merge!(attr_hash)
      end

      processed_atttibutes
    end

    def remove_quotations(str)
      if str.starts_with?('"')
        str = str.slice(1..-1)
      end
      if str.ends_with?('"')
        str = str.slice(0..-2)
      end
    end 

    def calculate_action(type, type_name)
      { 'create' => { "puppet_#{type}" => type_name } }
    end

    def string_to_boolean(string)
      if string.to_s == 'true'
        true
      elsif string.to_s == 'false'
        false
      end
    end

    def self.create(ast_obj, opts = {})
      new(ast_obj, opts)
    end

    TPS = [:hostclass, :definition]
    class TopPS < self
      def initialize(ast_array = nil, opts = {})
        self[:children] = []
        add_children(ast_array, opts)
        super
      end

      def add_children(ast_array, opts = {})
        return unless ast_array

        ast_array.instantiate('').each do |ast_item|
          ast_item_type = ast_item.type
          child =
            if TPS.include?(ast_item_type)
              ComponentPS.create(ast_item, opts)
            else
              fail DTK::Client::Error.new("Unexpected top level ast type (#{ast_item.class})")
            end
          self[:children] << child if child
        end
      end
    end

    class ComponentPS < self
      def initialize(ast_item, opts = {})
        ast_item_type = ast_item.type
        type =
          case ast_item_type
          when :hostclass
            'class'
          when :definition
            'definition'
          else
            fail DTK::Client::Error.new('unexpected type for ast_item')
          end

        self['type'] = type
        self['name'] = ast_item.name
        attributes  = []

        attributes << AttributePS.create_name_attribute if ast_item_type == :definition
        (ast_item.arguments || []).each { |arg| attributes << AttributePS.create(arg, opts) }

        self['attributes'] = attributes unless attributes.empty?
        super
      end
    end

    AttrTypes = {
      Puppet::Pops::Model::LiteralHash => 'hash',
      Puppet::Pops::Model::VariableExpression => 'string',
      Puppet::Pops::Model::LiteralUndef => 'string',
      Puppet::Pops::Model::LiteralBoolean => 'boolean',
      Puppet::Pops::Model::LiteralString => 'string',
      Puppet::Pops::Model::LiteralInteger => 'integer',
      Puppet::Pops::Model::LiteralList => 'array',
      Puppet::Pops::Model::ConcatenatedString => 'string',
      Puppet::Pops::Model::QualifiedName => 'string'
    }
    class AttributePS < self
      def initialize(arg, opts = {})
        self['name'] = arg[0]

        if arg_1 = arg[1]          
          self['type']     = type?(arg_1)
          self['required'] = opts[:required] if opts.key?(:required)

          unless def_value(arg_1)
            self['required'] ||= true
          end
        else
          self['type']     = 'string'
          self['required'] = true
        end

        super
      end

      def type?(arg)
        if arg_value = arg.value
          AttrTypes[arg_value.class] || 'string'
        else
          'string'
        end
      end

      def def_value(default_ast_obj)
        # if arg_value = default_ast_obj.value
        #   default_ast_obj.source_text unless IgnoreValues.include?(arg_value.class)
        # else
        default_ast_obj.source_text
        # end
      end
      # IgnoreValues = [Puppet::Pops::Model::VariableExpression]

      def self.create_name_attribute
        new(['name'], 'required' => true)
      end
    end

  end
end