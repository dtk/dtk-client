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
      subcommand_def 'push' do |c|
        c.desc 'Push updates in service module folder to server'
        c.command :push  do |sc|
          sc = Subcommand.new(sc)
          unless context_attributes[:service_name]
            sc.flag Term::Flag.service_instance, :desc => 'Name of service to push to server'
          end

          sc.action do |_global_options, options, _args|
            unless service_instance = options[:service_instance] || context_attributes[:service_instance]
              # This error only applicable if not in module
              raise Error::Usage, "The service instance reference must be given using option '#{option_ref(:service_instance)}'"
            end
            args = {
              :service_name => service_instance
            }
            Operation::Service.push(args)
          end
        end
      end
    end
  end
end; end
