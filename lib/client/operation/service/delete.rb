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
    class Delete < self
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          service_instance = args.required(:service_instance)
          recursive        = args.required(:recursive)
          force            = args[:force]
          directory_path   = args[:directory_path]

          unless args[:skip_prompt]
            return false unless Console.prompt_yes_no("Are you sure you want to delete the content of service instance '#{service_instance}' ?", :add_options => true)
          end

          DTK::Client::GitRepo.modified?(directory_path || OsUtil.current_dir) unless force
          post_body = PostBody.new(
            :service_instance => service_instance,
            :recursive? => recursive
          )
          rest_post("#{BaseRoute}/delete", post_body)

          OsUtil.print_info("DTK module '#{service_instance}' has been deleted successfully.")
        end
      end

    end
  end
end


