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
  class Operation
    class Service < self
      OPERATIONS = [
        :commit_and_push,
        :clone_service,
        :delete,
        :uninstall,
        :edit,
        :pull,
        :converge,
        :task_status,
        :list,
        :list_actions,
        :list_attributes,
        :list_component_links,
        :list_dependent_modules,
        :list_components,
        :list_nodes,
        :list_violations,
        :start,
        :stop,
        :cancel_task,
        :ssh,
        :set_required_attributes,
        :set_attribute,
        :exec,
        :set_default_target
        # :create_workspace
      ]
      OPERATIONS.each { |operation| require_relative("service/#{operation}") }

      BaseRoute = 'services'

      extend ModuleServiceCommon::ClassMixin

      private

      def self.service_exists?(service_ref, opts = {})
        response = rest_get("#{BaseRoute}/#{service_ref}/repo_info")
        response.data.empty? ? nil : response
      end
    end
  end
end
