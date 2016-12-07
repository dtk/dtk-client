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
  class Operation::Service
    class Uninstall < self
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          service_instance = args.required(:service_instance)
          recursive        = args.required(:recursive)
          force            = args.required(:force)

          unless args[:skip_prompt]
            return false unless Console.prompt_yes_no("Are you sure you want to uninstall the infrastructure associated with '#{service_instance}' and delete this service instance from the server?", :add_options => true)
          end

          post_body = PostBody.new(
            :service_instance => service_instance,
            :recursive? => recursive,
            :force      => force
          )
          rest_post("#{BaseRoute}/uninstall", post_body)

          ClientModuleDir.rm_f(args[:directory_path]) if args[:purge]

          OsUtil.print_info("DTK module '#{service_instance}' has been uninstalled successfully.")
        end
      end

    end
  end
end


