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
      subcommand_def 'update' do |c|
        command_body c, 'update', 'Update module dependencies to the latest available on dtk network' do |sc|
          sc.flag Token.directory_path, :desc => 'Absolute or relative path to module directory containing updates to publish; not need if in the module directory'
          sc.action do |_global_options, options, _args|
            module_ref = module_ref_object_from_options_or_context(options)
            Operation::Module.update(:module_ref => module_ref, :directory_path => options[:directory_path], :base_dsl_file_obj => @base_dsl_file_obj)
          end
        end
      end

    end
  end
end
