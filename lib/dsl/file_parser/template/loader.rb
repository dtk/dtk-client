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

class DTK::DSL::FileParser
  class Template
    class Loader
      TEMPLATE_VERSIONS = [1]

      # opts can have keys
      #  :dsl_version
      #  :template_version
      def self.template_class(template_type, opts = {})
        template_version = opts[:template_version] || template_version(opts[:dsl_version])
        load_version(template_version) unless version_loaded?(template_version)
        template_class_aux(template_type, template_version)
      end
      
      private
      
      def self.version_loaded?(template_version)
        @loaded_versions and @loaded_versions.include?(template_version)
      end
      
      def self.template_version(_dsl_version)
        # TODO: when have multiple versions thn want a mapping between
        # dsl version and template version, which could also be per template type
        # (i.e., same dsl version can map to different template versions depending on template_type)
        raise Error, "Unsupported when have multiple template versions" unless TEMPLATE_VERSIONS.size == 1
        TEMPLATE_VERSIONS.first
      end
      
      def self.load_version(template_version)
        require_relative("v#{template_version}")
        (@loaded_versions ||= []) << template_version
      end
      
      def self.template_class_aux(template_type, template_version)
        base_class = Template.const_get("V#{template_version}")
        base_class.const_get(::DTK::Common::Aux.snake_to_camel_case(template_type.to_s))
      end
    end
  end
end



