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
    class CloneService < self
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          service_ref       = args.required(:service_ref)
          service_name      = args.required(:service_name)
          target_directory = args[:target_directory]
          unless service_info = service_exists?(service_ref)
            raise Error::Usage, "DTK service '#{service_ref}' does not exist on server."
          end

          branch    = service_info.required(:branch, :name)
          repo_url  = service_info.required(:repo, :url)
          repo_name = service_info.required(:repo, :name)

          clone_args = {
            :repo_url    => service_info.required(:repo, :url),
            :branch      => service_info.required(:branch, :name),
            :service_instance => service_name,
            #:service_name => service_name,
            :repo_dir    => target_directory || ClientModuleDir.ret_path_with_current_dir(service_name)
          }

          ret = ClientModuleDir::GitRepo.clone_service_repo(clone_args)
          OsUtil.print_info("DTK service '#{service_ref}' has been successfully cloned into '#{ret.required(:target_repo_dir)}'")
        end
      end
    end
  end
end


