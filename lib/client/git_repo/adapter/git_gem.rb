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
        @local_branch_name = opts[:branch]
      end

      def self.clone(repo_url, target_path, branch)
        git_base = handle_git_error { ::Git.clone(repo_url, target_path) }
        begin
          git_base.checkout(branch)
        rescue => e
          # TODO: see if any other kind of error
          raise Error::Usage, "The branch or tag '#{branch}' does not exist on repo '#{repo_url}'"
        end
        git_base
      end

      # opts can have keys
      #  :new_branch - Boolean
      def checkout(branch, opts = {})
        ret = @git_repo.checkout(branch, opts)
        @local_branch_name = branch
        ret
      end

      def fetch(remote = 'origin')
        @git_repo.fetch(remote)
      end

      def add_remote(name, url)
        @git_repo.remove_remote(name) if is_there_remote?(name)
        @git_repo.add_remote(name, url)
      end

      def remove_remote(name)
        @git_repo.remove_remote(name) if is_there_remote?(name)
      end

      def push(remote, branch, opts = {})
        branch_name = current_branch ? current_branch.name : 'master'
        branch_for_push = "#{branch_name}:refs/heads/#{branch || local_branch_name}"
        @git_repo.push(remote, branch_for_push, opts)
      end

      def merge(branch_to_merge_from)
        @git_repo.merge(branch_to_merge_from)
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

      def stage_and_commit(commit_msg = nil)
        add_all
        begin
          commit(commit_msg || "DTK Commit from client")
        rescue
          # do not raise if nothing to commit
        end
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

      def add(*files)
        @git_repo.add(files.flatten)
      end

      def add_all
        @git_repo.add(:all => true)
      end

      def is_there_remote?(remote_name)
        @git_repo.remotes.find { |r| r.name == remote_name }
      end

      def current_branch
        @git_repo.branches.local.find { |b| b.current }
      end

      def remotes
        @git_repo.remotes
      end

      def head_commit_sha
        current_branch.gcommit.sha
      end

      def pull(remote, branch)
        @git_repo.pull(remote, branch)
      end

      def diff
        @git_repo.diff
      end

      def changed?
        (!(changed().empty? && untracked().empty? && deleted().empty?))
      end

      def print_status
        changes = [changed(), untracked(), deleted()]
        puts "\nModified files:\n".colorize(:green) unless changes[0].empty?
        changes[0].each { |item| puts "\t#{item}" }
        puts "\nAdded files:\n".colorize(:yellow) unless changes[1].empty?
        changes[1].each { |item| puts "\t#{item}" }
        puts "\nDeleted files:\n".colorize(:red) unless changes[2].empty?
        changes[2].each { |item| puts "\t#{item}" }
        puts "" 
      end

      def print_status_with_diff
        changes = [changed(), untracked(), deleted()]
        puts "\nThere are changes that are not pushed to teh server that will not be staged:\n".colorize(:green) unless changes[0].empty?
        diff = @git_repo.diff.stats[:files]
        file_changed = changes[0].size
        deletions = 0
        insertions = 0
        changes[0].each do |item|
          deletions += diff[item][:deletions]
          insertions += diff[item][:insertions]  
          puts "\t#{item} | #{insertions + deletions} " + "+".colorize(:green) * insertions + "-".colorize(:red) * deletions
        end
        puts "\t#{file_changed} file changed, #{deletions} deletions(-), #{insertions} insertions(+)"
        puts "\nAdded files:\n".colorize(:yellow) unless changes[1].empty?
        changes[1].each { |item| puts "\t#{item}" }
        puts "\nDeleted files:\n".colorize(:red) unless changes[2].empty?
        changes[2].each { |item| puts "\t#{item}" }
        puts "" 
      end
    end
  end
end
