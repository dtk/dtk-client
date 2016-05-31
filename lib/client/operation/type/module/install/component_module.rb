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
  class Operation::Module::Install
    class ComponentModule < self
      def self.install_modules(module_refs)
        # TODO DTK-2583: Aldin
        # This should work like the current behavior where when installing a service module
        # the code iterates over all the dependent modules and 
        # has the behavior
        #  Iterate over the list of dependent modules and for each DEP_MOD[_WITH_OPTIONAL_VERSION]
        #  do the following  (which is what we do today when installing component modules with exception in this new 
        # flow we dont pull the component module clones onto the client machine
        #   If DEP_MOD without version is not installed, install it on the serevr from the dtkn
        #   If DEP_MOD has a version and the version is not installed then install it on the server from the dtkn
        #  if DEP_MOD does not have a version and it is installed do an update on the server from dtkn after prompting whether to skip or not
        return if module_refs.empty?
      end
    end
  end
end


