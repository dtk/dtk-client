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
      subcommand_def 'pull-dtkn' do |c|
        command_body c, 'pull-dtkn', 'Pull content from dtk network to client module directory and push to server' do |sc|
          sc.flag Token.directory_path, :desc => 'Absolute or relative path to module directory containing content to update; not need if in the module directory'
          sc.switch Token.force
          sc.switch Token.update_deps
          sc.action do |_global_options, options, _args|
            module_ref = module_ref_object_from_options_or_context(options)
            operation_args = {
              :module_ref          => module_ref,
              :base_dsl_file_obj   => @base_dsl_file_obj,
              :has_directory_param => !options["d"].nil?,
              :directory_path      => options[:directory_path],
              #:skip_prompt         => options[:skip_prompt],
              :force               => options[:f],
              :update_deps         => options[:update_deps]
            }
            Operation::Module.pull_dtkn(operation_args)
            Operation::Module.push(operation_args.merge(:method => "pulled", context: self))
          end
        end
      end

    end
  end
end

