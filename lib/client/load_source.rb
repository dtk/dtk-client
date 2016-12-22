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
  class LoadSource
    require_relative('load_source/service_info')
    require_relative('load_source/component_info')

    def initialize(transform_helper, info_type, remote_repo_url, parent)
      @info_processor   = transform_helper.info_processor(info_type)
      @info_type        = info_type
      @remote_repo_url  = remote_repo_url
      @target_repo_dir  = parent.target_repo_dir
      @version          = parent.version
    end
    private :initialize

    def self.fetch_transform_and_merge(remote_module_info, parent)
      target_repo_dir      = parent.target_repo_dir
      transform_helper     = ServiceAndComponentInfo::TransformFrom.new(target_repo_dir, parent.module_ref, parent.version)
      info_types_processed = []

      if service_info = remote_module_info.data(:service_info)
        ServiceInfo.fetch_and_cache_info(transform_helper, service_info['remote_repo_url'], parent)
        info_types_processed << ServiceInfo.info_type
      end

      if component_info = remote_module_info.data(:component_info)
        ComponentInfo.fetch_and_cache_info(transform_helper, component_info['remote_repo_url'], parent)
        info_types_processed << ComponentInfo.info_type
      end

      unless info_types_processed.empty?
        transform_helper.output_path_text_pairs.each_pair do |path, text_content|
          Operation::ClientModuleDir.create_file_with_content("#{target_repo_dir}/#{path}", text_content)
        end
        stage_and_commit(target_repo_dir, commit_msg(info_types_processed))
      end
    end

    def self.fetch_and_cache_info(transform_helper, remote_repo_url, parent)
      new(transform_helper, info_type, remote_repo_url, parent).fetch_and_cache_info
    end
    
    private

    attr_reader :info_processor, :target_repo_dir

    def self.write_output_path_text_pairs(transform_helper, target_repo_dir, info_types_processed)
    end

    def common_git_repo_args
       {
        :info_type => @info_type,
        :repo_dir  => @target_repo_dir
      }
    end

    def git_repo_remote_branch
      (@version && !@version.eql?('master')) ? "v#{@version}" : 'master'
    end

    def fetch_remote
      git_repo_args = common_git_repo_args.merge(:add_remote => @remote_repo_url)
      git_repo_operation.fetch_dtkn_remote(git_repo_args)
    end

    def merge_from_remote
      git_repo_args = common_git_repo_args.merge(:remote_branch => git_repo_remote_branch, :no_commit => true)
      git_repo_operation.merge_from_dtkn_remote(git_repo_args)
    end

    def self.stage_and_commit(target_repo_dir, commit_msg = nil)
      git_repo_args = {
        :repo_dir          => target_repo_dir,
        :commit_msg        => commit_msg,
        :local_branch_type => :dtkn
      }
      git_repo_operation.stage_and_commit(git_repo_args)
    end

    def self.commit_msg(info_types_processed)
      msg = "Added "
      count = 0
      types = info_types_processed #info
      if types.include?(ServiceInfo.info_type)
        msg << 'service '
        count +=1
      end
      if types.include?(ComponentInfo.info_type)
        msg << 'and ' if count > 0
        msg << 'component'
        count +=1
      end
      msg << 'info'
      msg
    end

    def self.git_repo_operation
      Operation::ClientModuleDir::GitRepo
    end

    def git_repo_operation
      self.class.git_repo_operation
    end
  end
end
