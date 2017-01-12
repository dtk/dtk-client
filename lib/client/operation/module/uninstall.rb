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

          unless name.nil?
            query_string_hash = QueryStringHash.new(
              :detail_to_include => ['remotes', 'versions']
            )
            response = rest_get("#{BaseRoute}/list", query_string_hash)
            installed_modules = response.data

            name.gsub!("/", ":")
            installed_modules.each do |module_val| 
              if module_val["display_name"].eql? name
                val = name.split(":")
                if version.nil?
                  versions = module_val["versions"].split(",").map(&:strip) 
                  if versions.size > 1
                    version = Console.version_prompt(versions, "Select which module version to uninstall: ", { :add_all => true})
                    module_val["versions"] if version.eql? "all"
                  else
                    version = module_val["versions"]
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
          end 
          
          raise Error::Usage, "Invalid module name." if module_ref.nil?

          opts = {
            :namespace => module_ref.namespace,
            :version   => module_ref.version
          }

          unless args[:skip_prompt]
            return false unless Console.prompt_yes_no("Are you sure you want to uninstall module '#{DTK::Common::PrettyPrintForm.module_ref(module_ref.module_name, opts)}' from the server?", :add_options => true)
          end

          post_body = PostBody.new(
            :module_name => module_ref.module_name,
            :namespace   => module_ref.namespace,
            :version?    => module_ref.version
          )

          rest_post("#{BaseRoute}/delete", post_body)
          OsUtil.print_info("DTK module '#{DTK::Common::PrettyPrintForm.module_ref(module_ref.module_name, opts)}' has been deleted successfully.")
          nil
        end
      end

    end
  end
end


