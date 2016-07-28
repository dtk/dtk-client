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
module DTK::Client; module CLI
  module Command
    module Service
      subcommand_def 'delete' do |c|
        c.arg 'SERVICE-INSTANCE'
        command_body c, :delete, 'Deletes all the infrastructure associated with a service module folder and the contents of the folder' do |sc|
          sc.switch Token.skip_prompt
          sc.action do |_global_options, options, args|
            service_instance =  args[0]
            Operation::Service.delete(:service_instance => service_instance, :skip_prompt => options[:skip_prompt])
          end
        end
      end
    end
  end
end; end
