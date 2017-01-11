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
    class Converge < self
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          service_instance = args.required(:service_instance)
          module_dir   = args.required(:module_dir)
          force            = args[:force]

          post_body = PostBody.new(
            :service_instance => service_instance
          )

          error_msg = "To allow converge to go through, invoke 'dtk push' to push the changes to server before invoking converge again"
          GitRepo.modified_with_diff?(module_dir, { :error_msg => error_msg }) unless force
          violations = find_violations(service_instance)
          return violations if violations

          rest_post("#{BaseRoute}/#{service_instance}/converge", post_body)
        end
      end

      private

      def self.find_violations(service_instance)
        violations_response = rest_get("#{BaseRoute}/#{service_instance}/violations")

        if violations_response.data and violations_response.data.size > 0
          OsUtil.print_error("The following violations were found; they must be corrected before workspace can be converged")
          return violations_response.set_render_as_table!
        end

        nil
      end
    end
  end
end
