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
        def initialize(info_type, repo)
          @info_type = validate_info_type(info_type)
          @repo      = repo # object of type DTK::Client::GitRepo
        end
        private :initialize

        # returns object of type Dtkn
        def self.repo(info_type, repo_dir)
          git_repo = Internal.create_empty_git_repo?(repo_dir, :branch => local_branch)
          new(info_type, git_repo)
        end

        def add_remote(remote_url)
          Internal.add_remote(remote_name, @repo, remote_url)
        end

        def pull(remote_branch)
          Internal.pull(remote_name, @repo, remote_branch)
        end

        private

        # TODO: Deprecate GIT_REMOTE for below and LOCAL_BRANCH for below
        GIT_REMOTE   = 'dtkn'
        LOCAL_BRANCH = 'master'

        GIT_REMOTES = {
          :service_info   => GIT_REMOTE,
          :component_info => 'dtkn-component-info'
        }
        def remote_name
          GIT_REMOTES[@info_type] || raise(Error, "Bad info_type '#{@info_type}'")
        end

        def validate_info_type(info_type)
          raise Error, "Bad info_type '#{info_type}'" unless GIT_REMOTES.keys.include?(info_type)
          info_type
        end

        def self.remote_name
          GIT_REMOTES[@info_type]
        end

        def self.local_branch
          LOCAL_BRANCH
        end

      end
    end
  end
end        
