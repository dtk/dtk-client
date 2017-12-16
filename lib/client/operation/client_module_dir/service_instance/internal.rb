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
  class Operation::ClientModuleDir
    class ServiceInstance
      # All Internal methods do not have wrap_operation and can only be accessed by a method that wraps it
      class Internal < self
        require_relative('internal/module_info')

        def initialize(args)
          @base_module      = args.required(:base_module)
          @nested_modules   = args.required(:nested_modules)
          @service_instance = args.required(:service_instance)
          @remove_existing  = args[:remove_existing]
          @repo_dir         = args[:repo_dir]
        end
        private :initialize

        def self.clone(args)
          new(args).clone
        end

        def clone
          @target_repo_dir = clone_base_module
          @nested_module_base = make_nested_module_base
          self.nested_modules.each { |nested_module| clone_nested_module(nested_module) }
          self.target_repo_dir
        end
          
        protected

        attr_reader :base_module, :nested_modules, :service_instance, :remove_existing, :repo_dir

        def target_repo_dir
          @target_repo_dir || raise(Error, "Unexpected that @target_repo_dir is nil")
        end

        def nested_module_base
          @nested_module_base || raise(Error, "Unexpected that @nested_module_base is nil")
        end

        private

        def clone_base_module
          module_info = ModuleInfo.new(self.base_module)
          target_repo_dir = self.class.create_service_dir(self.service_instance, :remove_existing => self.remove_existing, :path => self.repo_dir)
          clone_repo(module_info, target_repo_dir)
          target_repo_dir
        end

        def clone_nested_module(nested_module_hash)
          module_info     = ModuleInfo.new(nested_module_hash)
          nested_repo_dir = "#{self.nested_module_base}/#{module_info.module_name}"
          clone_repo(module_info, nested_repo_dir)
        end

        POSSIBLE_NESTED_MODULE_BASES = ['modules', 'dtk-modules']
        def make_nested_module_base
          unless nested_module_base = find_unused_path?(POSSIBLE_NESTED_MODULE_BASES)
            raise Error::Usage, "The module must not have files/directories that conflict with each of #{POSSIBLE_NESTED_MODULE_BASES.join(', ')}"
          end
          FileUtils.mkdir_p(nested_module_base)
          nested_module_base
        end

        def find_unused_path?(dirs)
          dirs.map { |dir| "#{self.target_repo_dir}/#{dir}" }.find { |full_path| ! File.exists?(full_path) }
        end

        def clone_repo(module_info, target_repo_dir)
          clone_args = {
            :repo_url        => module_info.repo_url,
            :branch          => module_info.branch,
            :target_repo_dir => target_repo_dir
          }
          response = ClientModuleDir::GitRepo.clone(clone_args)
          raise Error::Usage, response.data unless response.ok?
        end
        
      end
    end
  end
end

