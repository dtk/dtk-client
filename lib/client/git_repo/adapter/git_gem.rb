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
require 'git'

module DTK::Client
  module GitRepo::Adapter
    class GitGem
      require_relative('git_gem/error_handler')
      
      include ErrorHandler::Mixin
      extend ErrorHandler::Mixin
      
      attr_accessor :git_repo
      
      # opts can have keys
      #  :branch
      def initialize(repo_dir, opts = {})
        @git_repo = ::Git.init(repo_dir)
        # If we want to log Git interaction
        # @git_repo = ::Git.init(repo_dir, :log => Logger.new(STDOUT))
        @local_branch_name = opts[:branch_name]
      end

      def self.clone(repo_url, target_path, branch)
        git_base = handle_git_error { ::Git.clone(repo_url, target_path) }
        pp [git_base.class, git_base]
        begin
          git_base.checkout(branch)
        rescue => e
          # TODO: see if any other kind of error
          raise Error::Usage, "The branch or tag '#{branch}' does not exist on repo '#{repo_url}'"
        end
        git_base
      end

      def add_remote(name, url)
        @git_repo.remove_remote(name) if is_there_remote?(name)
        @git_repo.add_remote(name, url)
      end

      def push(remote, branch, opts = {})
        branch_name = current_branch ? current_branch.name : 'master'
        branch_for_push = "#{branch_name}:refs/heads/#{branch||local_branch_name}"
        @git_repo.push(remote, branch_for_push, opts)
      end

      def status
        @git_repo.status
      end

      def changed
        status.is_a?(Hash) ? status.changed().keys : status.changed().collect { |file| file.first }
      end

      def untracked
        status.is_a?(Hash) ? status.untracked().keys : status.untracked().collect { |file| file.first }
      end

      def deleted
        status.is_a?(Hash) ? status.deleted().keys : status.deleted().collect { |file| file.first }
      end

      def added
        status.is_a?(Hash) ? status.added().keys : status.added().collect { |file| file.first }
      end

      def stage_and_commit(commit_msg = "")
        stage_changes()
        commit("Initial commit")
      end

      def stage_changes()
        handle_git_error do
          @git_repo.add(untracked())
          @git_repo.add(added())
          @git_repo.add(changed())
        end
        deleted().each do |file|
          begin
            @git_repo.remove(file)
          rescue
            # ignore this error means file has already been staged
            # we cannot support status of file, in 1.8.7 so this is
            # solution for that
          end
        end
      end

      def commit(commit_msg = "")
        @git_repo.commit(commit_msg)
      end

      def is_there_remote?(remote_name)
        @git_repo.remotes.find { |r| r.name == remote_name }
      end

      def current_branch()
        @git_repo.branches.local.find { |b| b.current }
      end
    end
  end
end
