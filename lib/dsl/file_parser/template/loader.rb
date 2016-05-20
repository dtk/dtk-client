#
# Copyright (C) 2010-2016 dtk contributors
#
# This file is part of the dtk project.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
require 'singleton'
module DTK::DSL; class FileParser
  class Template
    class Loader
      include Singleton
      
      TEMPLATE_VERSIONS = [1]
      TEMPLATE_VERSIONS.each { |template_version| require_relative("v#{template_version.to_s}") }
      
      def initialize
        @loaded_templates = {}
      end
      private :initialize
      
      def self.template_class(template_type, dsl_version)
        instance.template_class(template_type, dsl_version)
      end
      
      def template_class(template_type, dsl_version)
        template_version = template_version(dsl_version, template_type)
        cached_template?(template_type, template_version) || load_template_class(template_type, template_version)
      end
      
      private
      
      def template_version(_dsl_version, _template_type)
        # TODO: when have multiple versions tehn want a mapping between
        # dsl version and template version, which could also be per template type
        # (i.e., same dsl version can map to different template versions depending on template_type)
        raise Error, "Unsupported wen have multiple template versions" unless TEMPLATE_VERSIONS.size == 1
        TEMPLATE_VERSIONS.first
      end
      
      def load_template_class(template_type, template_version)
        unless Template::TYPES.include?(template_type)
          raise Error.new("Illegal parse template type '#{template_type}'") 
        end
        require_relative("v#{template_version}/#{template_type}")
        
        base_class = Template.const_get("V#{template_version}")
        klass = base_class.const_get(::DTK::Common::Aux.snake_to_camel_case(template_type.to_s))
        set_cached_template!(template_type, template_version, klass)
      end
      
      def cached_template?(template_type, template_version) 
        (@loaded_templates[template_version] || {})[template_type]
      end
      
      def set_cached_template!(template_type, template_version, klass)
        (@loaded_templates[template_version] ||= {})[template_type] = klass
      end
    end
  end
end; end
