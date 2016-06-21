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
  class Operation::Module
    class Push < self
      def self.push(args = Args.new)
        wrap_as_response(args) do |args|
          module_ref  = args.required(:module_ref)
          # TODO: Aldin 6/21/2016:
          # Put in logic that calls the new vewrsion of module_exists? explained in ../modules.rb
          # pulls the needed parms so it could call the code sketched below
          # unless module_info = module_exists?(module_ref, :common)
          #  raise error that module does not exist
          # end
          # pull needed params from module_info so can call
          # BaseRoute/update_from_repo
          nil
        end
      end
    end
  end
end


