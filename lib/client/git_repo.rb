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
  # Wrapper from gem that does the git interaction
  class GitRepo
    require_relative('git_repo/git_adapter')
    
    # opts can have keys
    #  :branch
    def self.create(repo_dir, opts = {})
      new(repo_dir, opts)
    end
    
    def initialize(repo_dir, opts = {})
      @git_adapter = self.class.git_adapter_class.new(repo_dir, opts)
    end
    private :initialize
    
    def self.clone(repo_url, target_path, branch)
      @git_adapter.clone(repo_url, target_path, branch)
    end
    
    private
    
    def self.git_adapter_class
      GitAdapter
    end

  end
end