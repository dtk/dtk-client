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
  class Operation::ClientModuleDir::GitRepo
    class Internal
      class Dtkn 
        def initialize(info_type, repo_dir)
          @info_type = validate_info_type(info_type)
          @repo      = Internal.create_empty_git_repo?(repo_dir, :branch => local_branch)
        end
        private :initialize

        # returns object of type self
        # opts can have keys
        #   :add_remote - if set has the remote url
        def self.repo_with_remote(info_type, repo_dir, opts = {})
          remote_url = opts[:add_remote]

          repo_with_remote = new(info_type, repo_dir)
          repo_with_remote.add_remote(remote_url) if remote_url
          repo_with_remote
        end

        def add_remote(remote_url)
          Internal.add_remote(@repo, remote_name, remote_url)
        end

        def fetch
          Internal.fetch(@repo, remote_name)
        end

        # opts can have keys
        #   :no_commit
        def merge_from_remote(remote_branch, opts = {})
          merge_from_ref = "#{remote_name}/#{remote_branch}"
          Internal.merge(@repo, merge_from_ref, :no_commit => opts[:no_commit], :use_theirs => opts[:use_theirs])
        end

        def local_ahead?(remote_branch, opts = {})
          merge_from_ref = "#{remote_name}/#{remote_branch}"
          Internal.local_ahead?(@repo, merge_from_ref, :no_commit => opts[:no_commit])
        end

        def reset_hard(remote_branch, opts = {})
          merge_from_ref = opts[:branch] || "#{remote_name}/#{remote_branch}"
          Internal.reset_hard(@repo, merge_from_ref)
        end

        private

        # TODO: These constants used in Internal; Deprecate GIT_REMOTE amd LOCAL_BRANCH for remote_name and local_branch
        GIT_REMOTE   = 'dtkn'
        LOCAL_BRANCH = 'master'

        GIT_REMOTES = {
          :service_info   => GIT_REMOTE,
          :component_info => 'dtkn-component-info'
        }
        def remote_name
          GIT_REMOTES[@info_type]
        end

        def self.local_branch
          LOCAL_BRANCH
        end
        def local_branch
          self.class.local_branch
        end

        def validate_info_type(info_type)
          raise Error, "Bad info_type '#{info_type}'" unless GIT_REMOTES.keys.include?(info_type)
          info_type
        end

      end
    end
  end
end        
