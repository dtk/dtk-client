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
  # Abstract class that holds classes and methods for executing commands by
  # make calls to server and performing client side operations
  class Operation
    TYPES = [:account, :module]
    TYPES.each { |op_type| require_relative("operation/#{op_type}") }
      
    private
    
    # delegate rest calls to Session
    def self.rest_post(route, post_body = {})
      Session.rest_post(route, post_body)
    end
    def self.rest_get(route, args = {})
      Session.rest_get(route, args)
    end
  end
end

