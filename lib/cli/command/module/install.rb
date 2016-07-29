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
      subcommand_def 'install' do |c|
        c.arg 'MODULE-PATH', :optional => true
        command_body c, :install, 'Install DTK module from local dirctory to server' do |sc|
          sc.action do |_global_options, _options, args|
            if module_dir_path = args[0]
              set_base_dsl_file_obj!(:dir_path => module_dir_path)
            end
            module_ref = context_attributes[:module_ref]
            Operation::Module.install(:module_ref => context_attributes[:module_ref], :base_dsl_file_obj => @base_dsl_file_obj)
          end
        end
      end
    end
  end
end

