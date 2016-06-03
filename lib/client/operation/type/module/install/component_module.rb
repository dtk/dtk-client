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
  class Operation::Module::Install
    class ComponentModule < self
      BaseRoute = "modules"

      def self.install_modules(module_refs)
        return if module_refs.empty?

        module_refs.each do |module_ref|
          post_body = {
            :remote_module_name => "#{module_ref.namespace}/#{module_ref.module_name}",
            :local_module_name => module_ref.module_name,
            :rsa_pub_key => SSHUtil.rsa_pub_key_content()
          }

          if version = module_ref.version
            post_body.merge!(:version => module_ref.version)
          end

          # if module exists skip for now
          next if module_exists?(module_ref, "component_module")

          rest_post "#{BaseRoute}/install_component_module", PostBody.new(post_body)
        end
      end
    end
  end
end


