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
# This code is predciated on assumption that they is only one local branch (with with documented exceptions)
# so checkout branch is not done in most cases

module DTK::Client 
  # Wrapper around gem that does the git operations
  class GitRepo
    module Adapter
      require_relative('git_repo/adapter/git_gem')
    end

    # opts can have keys
    #  :branch
    def initialize(repo_dir, opts = {})
      @git_adapter = git_adapter_class.new(repo_dir, opts)
    end

    def self.clone(repo_url, target_path, branch)
      git_adapter_class.clone(repo_url, target_path, branch)
    end

    def self.is_git_repo?(dir)
      File.directory?("#{dir}/.git")
    end

    def self.unlink_local_clone?(dir)
      git_dir = "#{dir}/.git"
      if File.directory?(git_dir)
        FileUtils.rm_rf(git_dir)
      end
    end

    def self.modified?(dir)
      repo_dir = {
        :path    => dir,
        :branch  => Git.open(dir).branches.local
      }
      message = DTK::Client::Operation::ClientModuleDir::GitRepo.modified(repo_dir)
      if message.data(:modified)
        raise Error::Usage, "Please push or revert changes."
      end
    end

    def self.modified_with_diff?(dir, opts = {})
      repo_dir = {
        :path    => dir,
        :branch  => Git.open(dir).branches.local
      }

      message = DTK::Client::Operation::ClientModuleDir::GitRepo.modified_with_diff(repo_dir)
      if message.data(:modified)
        error_msg = opts[:error_msg] || "To allow push to go through, use option '-f' or invoke 'dtk push' to push the changes before invoking stage again"
        raise Error::Usage, error_msg
      end
    end

    def add_remote(name, url)
      @git_adapter.add_remote(name, url)
    end

    def changed?
      @git_adapter.changed?
    end

    # opts can have keys
    #  :new_branch - Boolean
    def checkout(branch, opts = {})
      @git_adapter.checkout(branch, opts)
    end

    def current_branch
      @git_adapter.current_branch
    end

    def diff
      @git_adapter.diff
    end

    def fetch(remote = 'origin')
      @git_adapter.fetch(remote)
    end

    def head_commit_sha
      @git_adapter.head_commit_sha
    end

    def is_there_remote?(remote_name)
      @git_adapter.is_there_remote?(remote_name)
    end

    def merge(branch_to_merge_from)
      @git_adapter.merge(branch_to_merge_from)
    end

    # opts can have keys:
    #   :with_diffs (Boolean)
    def print_status(opts = {})
      @git_adapter.print_status(opts)
    end

    def push(remote, branch, opts = {})
      @git_adapter.push(remote, branch, opts)
    end

    def push_from_cached_branch(remote, branch, opts = {})
      @git_adapter.push_from_cached_branch(remote, branch, opts)
    end

    def pull(remote, branch)
      @git_adapter.pull(remote, branch)
    end

    def remotes
      @git_adapter.remotes
    end

    def remove_remote(name)
      @git_adapter.remove_remote(name)
    end

    def stage_and_commit(commit_msg = nil)
      @git_adapter.stage_and_commit(commit_msg)
    end

    def empty_commit(commit_msg = nil)
      @git_adapter.empty_commit(commit_msg)
    end

    def reset_soft(sha)
      @git_adapter.reset_soft(sha)
    end

    private
    
    def git_adapter_class
      self.class.git_adapter_class
    end

    def self.git_adapter_class
      Adapter::GitGem
    end
  end
end
