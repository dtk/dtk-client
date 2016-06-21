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
    class Delete < self
      def self.delete(args = Args.new)
        wrap_as_response(args) do |args|
          module_ref  = args.required(:module_ref)
          return false unless Console.prompt_yes_no("Are you sure you want to delete DTK module '#{module_ref.print_form}'?", :add_options => true)

          post_body = PostBody.new(
            :module_name => module_ref.module_name,
            :namespace   => module_ref.namespace
          )
          rest_post("#{BaseRoute}/delete", post_body)
          OsUtil.print_info("DTK module '#{module_ref.print_form}' has been deleted successfully.")
        end
      end

    end
  end
end

