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
# This is wrapper for holding rest response information as well as
# passing selection of ViewProcessor from Thor selection to render view
# selection
require 'dtk_common_core' 

module DTK::Client
  class Response < ::DTK::Common::Response
    require_relative('response/error_handler')
    require_relative('response/render_helper')
    require_relative('response/subclasses')

    include RenderHelperMixin

    def initialize(hash = {})
      super(hash)
      @print_error_table = false #we use it if we want to print 'error legend' for given tables 
      render_attributes_init!
    end

    # opts can be
    #  :default_error_if_nil - Boolean
    def error_info?(opts = {})
      ErrorHandler.error_info?(self, opts)
    end
    
    # This method is used so that client side actions can be wrapped like calls to server
    def self.wrap_as_response(data = {}, &block)
      results = (block ? yield : data)
      if results.nil?
        NoOp.new
      elsif results.kind_of?(Response)
        results
      else
        Ok.new(results)
      end
    end
  end
end

