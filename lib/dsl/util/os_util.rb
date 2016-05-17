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
module DTK::DSL
  module OsUtil
    def self.method_missing(method, *args, &body)
      base_module.respond_to?(method) ? base_module.send(method, *args, &body) : super
    end

    def self.respond_to?(method)
      base_module.respond_to?(method) or super
    end

    private

    def self.base_module
      DTK::DSL.delegate_module.os_util_module
    end
  end
end
