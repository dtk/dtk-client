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
    class CloneModule < self
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          module_ref       = args.required(:module_ref)
          module_name      = args.required(:module_name)
          target_directory = args[:target_directory]

          unless module_info = module_exists?(module_ref, :type => :common_module)
            raise Error::Usage, "DTK module '#{module_ref.print_form}' does not exist on server."
          end

          branch    = module_info.required(:branch, :name)
          repo_url  = module_info.required(:repo, :url)
          repo_name = module_info.required(:repo, :name)

          clone_args = {
            :module_type => :common_module,
            :repo_url    => module_info.required(:repo, :url),
            :branch      => module_info.required(:branch, :name),
            :module_name => module_name,
            :repo_dir    => target_directory || ClientModuleDir.ret_path_with_current_dir(module_name)
            # :remove_existing  => remove_existing
          }

          ret = ClientModuleDir::GitRepo.clone_module_repo(clone_args)
          OsUtil.print_info("DTK module '#{module_ref.print_form}' has been successfully cloned into '#{ret.required(:target_repo_dir)}'")
        end
      end
    end
  end
end


