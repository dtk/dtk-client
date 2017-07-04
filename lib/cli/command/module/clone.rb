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
  module CLI::Command
    module Module 
      subcommand_def 'clone' do |c|
        c.arg Token::Arg.module_name
        c.arg Token::Arg.target_directory, :optional => true
        command_body c, :clone, 'Clone content from server module directory to client' do |sc|
          sc.flag Token.version
          sc.action do |_global_options, options, args|
            module_name = args[0]
            version     = options[:version]
            module_ref  = module_ref_object_from_options_or_context(:module_ref => module_name, :version => version)

            arg = {
              :module_ref => module_ref,
              :target_directory => args[1]
            }
            repo_dir_info = Operation::Module.clone_module(arg).data
            repo_dir      = repo_dir_info[:target_repo_dir]

            # DTK-3088 - need this to pull service info for dependency module on clone
            if repo_dir_info[:pull_service_info] && (version.nil? || version.eql?('master'))
              repo_dir = repo_dir_info[:target_repo_dir]
              module_ref = module_ref_object_from_options_or_context(:directory_path => repo_dir)

              operation_args = {
                :module_ref          => module_ref,
                :base_dsl_file_obj   => @base_dsl_file_obj,
                :has_directory_param => true,
                :directory_path      => repo_dir,
                :update_deps         => false,
                :do_not_print        => true,
                :force               => true
              }

              Operation::Module.pull_dtkn(operation_args)
              Operation::Module.push(operation_args.merge(:method => "pulled"))
            end

            OsUtil.print_info("DTK module '#{module_ref.pretty_print}' has been successfully cloned into '#{repo_dir}'")
          end
        end
      end

    end
  end
end

