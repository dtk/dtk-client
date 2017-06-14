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
    class InstallOnServer < self
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          module_ref = args.required(:module_ref)
          post_body = {
            :module_name => module_ref.module_name,
            :namespace   => module_ref.namespace,
            :rsa_pub_key => SSHUtil.rsa_pub_key_content,
            :version?    => module_ref.version
          }
          rest_post("#{BaseRoute}/install_on_server", post_body)
        end
      end

    end
  end
end


