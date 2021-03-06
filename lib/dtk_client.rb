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
module DTK
  module Client
    require_relative('client/util')
    require_relative('client/module_ref')

    # util and module_ref must be loaded first
    require_relative('client/logger')
    require_relative('client/error')
    require_relative('client/config')
    require_relative('client/configurator')
    require_relative('client/response')
    require_relative('client/conn')
    require_relative('client/session')
    require_relative('client/git_repo')
    require_relative('client/operation')
    require_relative('client/operation_args')
    require_relative('client/render')
    require_relative('client/service_and_component_info')
    require_relative('client/load_source')
  end
end
