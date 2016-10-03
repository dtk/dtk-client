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
    class SetRequiredAttributes < self
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          service_instance    = args.required(:service_instance)
          response            = rest_get "#{BaseRoute}/#{service_instance}/required_attributes"
          required_attributes = response.data

          if required_attributes.empty?
            OsUtil.print_info("No parameters to set.")
          else
            param_bindings = InteractiveWizard.resolve_missing_params(required_attributes)

            post_body = PostBody.new(
              :service_instance => service_instance,
              :av_pairs_hash    => param_bindings.inject(Hash.new){|h,r|h.merge(r[:id] => r[:value])}
            )
            response = rest_post "#{BaseRoute}/#{service_instance}/set_attributes", post_body

            repo_info_args = Args.new(
              :service_instance => service_instance,
              :branch           => response.required(:branch, :name),
              :repo_url         => response.required(:repo, :url)
            )
            ClientModuleDir::GitRepo.pull_from_service_repo(repo_info_args)

            nil
          end
        end
      end
    end
  end
end
