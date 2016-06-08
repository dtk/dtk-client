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
  class GitRepo
    class GitAdapter
      require_relative('git_adapter/error_handler')
      
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
        begin
          git_base.checkout(branch)
        rescue => e
          # TODO: see if any other kind of error
          raise Error::Usage, "The branch or tag '#{branch}' does not exist on repo '#{repo_url}'"
        end
        git_base
      end
    end
  end
end

