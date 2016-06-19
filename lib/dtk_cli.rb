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
require 'pp'
module DTK
  module Client
    module CLI
      require_relative('cli/version')
      require_relative('cli/runner')
      require_relative('cli/processor')
      require_relative('cli/command')
      # processor and command must go before context
      require_relative('cli/context')
      require_relative('cli/directory_parser')
    end
  end
end
