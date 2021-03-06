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
    class Uninstall < self
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          module_ref  = args.required(:module_ref)
          name        = args.required(:name)
          version     = args.required(:version)
          force       = args.required(:force)
  
          unless name.nil?
            query_string_hash = QueryStringHash.new(
              :detail_to_include => ['remotes', 'versions']
            )
            response = rest_get("#{BaseRoute}/list", query_string_hash)
            installed_modules = response.data

            module_ref = process_module_ref(installed_modules, name, version) 
          end 

          raise Error::Usage, "Invalid module name." if module_ref.nil?

          delete_versions = module_ref.version

          unless args[:skip_prompt]
            if delete_versions && delete_versions.is_a?(Array) 
               return false unless Console.prompt_yes_no("Are you sure you want to uninstall all module versions for '#{module_ref.namespace}/#{module_ref.module_name}' from the DTK Server?", :add_options => true) 
            else
              return false unless Console.prompt_yes_no("Are you sure you want to uninstall module '#{module_ref.pretty_print}' from the DTK Server?", :add_options => true) 
            end
            
          end
          post_body = module_ref_post_body(module_ref)
          post_body.merge!(:force => force)
          rest_post("#{BaseRoute}/delete", post_body)

          error_msg =
            if delete_versions && delete_versions.is_a?(Array) && delete_versions.size > 1
              "All versions of dtk module '#{module_ref.namespace}/#{module_ref.module_name}' have been uninstalled."
            else
              "DTK module '#{module_ref.pretty_print}' has been uninstalled successfully."
            end

          OsUtil.print_info(error_msg)
          nil
        end
      end
      
        def self.process_module_ref(installed_modules, name, version)
          name.gsub!('/', ':')
          module_ref = nil

          installed_modules.each do |module_val| 
            if module_val["display_name"].eql? name
              val = name.split(":")
              if version.nil?
                versions = module_val["versions"].split(",").map(&:strip) 
                versions.each { |value| value.tr!('*', '') }

                if versions.size > 1
                  version = Console.version_prompt(versions, "Select which module version to uninstall: ", { :add_all => true})
                  version = versions if version.eql? "all"
                else
                  version = module_val["versions"]
                  version.tr!('*', '') if version.include?('*')
                end
              end

              module_opts = {
                :module_name => val[1],
                :namespace   => val[0],
                :version     => version
              }
              
              module_ref = ModuleRef.new(module_opts) 
            end
          end

          module_ref
        end

    end
  end
end


