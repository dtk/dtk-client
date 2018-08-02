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

        def self.clone_nested_modules(args)
          new(args).clone_nested_modules
        end

        def clone_nested_modules
          @target_repo_dir = self.repo_dir
          @nested_module_base = self.class.find_nested_modules_dir(self.repo_dir)
          self.nested_modules.each { |nested_module| clone_nested_module(nested_module) }
        end

        def clone
          @target_repo_dir = clone_base_module
          @nested_module_base = make_nested_module_base
          self.nested_modules.each { |nested_module| clone_nested_module(nested_module) }
          self.target_repo_dir
        end

        def self.commit_and_push_nested_modules(args)
          service_instance     = args[:service_instance]
          service_instance_dir = args[:service_instance_dir] || ret_base_path(:service, service_instance)

          nested_modules_dir = find_nested_modules_dir(service_instance_dir)
          nested_modules     = Dir.glob("#{nested_modules_dir}/*")

          nested_modules_with_sha = []
          nested_modules.each do |nested_module|
            nested_module_name = nested_module.split('/').last
            response = ClientModuleDir::GitRepo.commit_and_push_to_nested_module_repo({target_repo_dir: nested_module})
            if head_sha = response.data(:head_sha)
              nested_modules_with_sha << { nested_module_name => head_sha }
            end
          end

          nested_modules_with_sha
        end

        def self.modified_service_instance_or_nested_modules?(args)
          service_instance_dir = args.required(:dir)
          command   = args.required(:command)
          error_msg = args.required(:error_msg)

          is_modified?(service_instance_dir, command, error_msg)

          nested_modules_dir = find_nested_modules_dir(service_instance_dir)
          nested_modules     = Dir.glob("#{nested_modules_dir}/*")

          nested_modules.each do |nested_module|
            nested_module_name = nested_module.split('/').last
            nested_error_msg = "There are uncommitted changes in nested module '#{nested_module_name}'! #{error_msg}"
            is_modified?(nested_module, command, nested_error_msg)
          end
        end

        protected

        attr_reader :base_module, :nested_modules, :service_instance, :remove_existing, :repo_dir

        def target_repo_dir
          @target_repo_dir || raise(Error, "Unexpected that @target_repo_dir is nil")
        end

        def nested_module_base
          @nested_module_base || raise(Error, "Unexpected that @nested_module_base is nil")
        end

        def possible_nested_module_base_dirs
          self.class.possible_nested_module_base_dirs
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

        def make_nested_module_base
          unless nested_module_base = find_unused_path?(self.possible_nested_module_base_dirs)
            raise Error::Usage, "The module must not have files/directories that conflict with each of #{self.possible_nested_module_base_dirs.join(', ')}"
          end
          FileUtils.mkdir_p(nested_module_base)
          nested_module_base
        end

        def find_unused_path?(dirs)
          dirs.map { |dir| "#{self.target_repo_dir}/#{dir}" }.find { |full_path| ! File.exists?(full_path) }
        end

        def self.find_nested_modules_dir(service_instance_dir)
          self.possible_nested_module_base_dirs.map { |dir| "#{service_instance_dir}/#{dir}" }.find { |full_path| File.exists?(full_path) }
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

        def self.possible_nested_module_base_dirs
          @possible_nested_module_base_dirs ||= ::DTK::DSL::DirectoryType::ServiceInstance::NestedModule.possible_paths
        end

        def self.is_modified?(path, command, error_msg)
          repo_dir = {
            :path    => path,
            :branch  => Git.open(path).branches.local,
            :command => command
          }
          message = ClientModuleDir::GitRepo.modified_with_diff(repo_dir)
          raise Error::Usage, error_msg if message.data(:modified)
        end
        
      end
    end
  end
end

