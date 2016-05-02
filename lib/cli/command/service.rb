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
module DTK::CLI
  class Context
    class Service < self
    end

    private
      
    def add_command_defs__service!
      desc 'Describe service here'
      arg_name 'Describe arguments to service here'
      command :service do |c|
        c.desc 'Describe a switch to service'
        c.switch :s
        
        c.desc 'Describe a flag to service'
        c.default_value 'default'
        c.flag :f
        c.action do |global_options, options, args|
          
          # Your command logic here
          
          # If you have any errors, just raise them
          # raise "that command made no sense"
          pp [global_options, options, args]
          puts "service command ran"
        end
      end
    end
  end
end

