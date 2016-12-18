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
module DTK::Client
  class Operation::Module
    class Install < self
      require_relative('install/mixin')
      # mixin must go first
      require_relative('install/print_helper')
      require_relative('install/module_ref')
      require_relative('install/dependent_modules')
      require_relative('install/common_module')

      def initialize(file_obj, module_ref)      
        @file_obj         = file_obj
        @base_module_ref  = module_ref
        @parsed_module    = file_obj.parse_content(:common_module_summary)
        @print_helper     = PrintHelper.new(:module_ref => @base_module_ref)
      end
      private :initialize

      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          module_ref             = args.required(:module_ref) 
          base_dsl_file_obj      = args.required(:base_dsl_file_obj)
          has_directory_param    = args[:has_directory_param]
          skip_prompt            = args[:skip_prompt]
          has_remote_repo  = args[:has_remote_repo]

          if has_directory_param
            file_obj = args.required(:base_dsl_file_obj).raise_error_if_no_content_flag(:module_ref)
          else
            file_obj = args.required(:base_dsl_file_obj).raise_error_if_no_content
          end

          new(file_obj, module_ref).install(:skip_prompt => skip_prompt, :has_remote_repo => has_remote_repo)
        end
      end

      # opts can have keys:
      #   :skip_prompt
      #   :has_remote_repo
      def install(opts = {})
        unless @base_module_ref
          raise Error::Usage, "No base module reference #{dsl_path_ref}"
        end

        if module_exists?(@base_module_ref, { :type => :common_module })
          raise Error::Usage, "Module '#{@base_module_ref.print_form}' exists already"
        end

        unless dependent_modules.empty?
          begin 
            DependentModules.install(@base_module_ref, dependent_modules, :skip_prompt => opts[:skip_prompt])
          rescue TerminateInstall
            @print_helper.print_terminated_installation
            return nil
          end
        end

        @print_helper.print_continuation_installing_base_module
        CommonModule.install(@base_module_ref, @file_obj, :has_remote_repo => opts[:has_remote_repo])
        @print_helper.print_done_message
        nil
      end
      
      class TerminateInstall < ::Exception
      end

      private

      def dependent_modules
        @dependent_modules ||= compute_dependent_modules
      end

      def compute_dependent_modules
        base_component_module_found = false 
        ret = (@parsed_module.val(:DependentModules) || []).map do |parsed_module_ref| 
          dep_module_name = parsed_module_ref.req(:ModuleName)
          dep_namespace   = parsed_module_ref.req(:Namespace)
          dep_version     = parsed_module_ref.val(:ModuleVersion)
          if is_base_module = (dep_module_name == module_name)
            # This is for legacy modules
            base_component_module_found = true
          end
          ModuleRef.new(:namespace => dep_namespace, :module_name => dep_module_name, :version => dep_version, :is_base_module => is_base_module)
        end
        unless base_component_module_found
          if module_exists?(@base_module_ref, :type => :component_module)
            ret << ModuleRef.new(:namespace => namespace, :module_name => module_name, :version => version, :is_base_module => true)
          end
        end
        ret
      end

      def namespace  
        @base_module_ref.namespace
      end

      def module_name 
        @base_module_ref.module_name
      end

      def version  
        @base_module_ref.version
      end

      def components
        # TODO: check if we can use @parsed_module instead of @file_obj.yaml_parse_hash
        @components ||= (@file_obj.yaml_parse_hash||{})['components']
      end

      def dsl_path_ref
        if path = @file_obj.path?
          "in the dsl file '#{path}'"
        else
          "in the dsl file"
        end
      end

    end
  end
end


