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
    
    # This method is used so that client side actions can be wrapped like server responses
    def self.wrap_helper_actions(data = {}, &block)
      begin
        results = (block ? yield : data)
        Ok.new(results)
        
      rescue Git::GitExecuteError => e
        if e.message.include?('Please make sure you have the correct access rights')
          error_msg  = "You do not have git access from this client, please add following SSH key in your git account: \n\n"
          error_msg += "#{SSHUtil.rsa_pub_key_content()}\n"
          raise Error, error_msg
        end
        handle_error_in_wrapper(e)
       rescue ErrorUsage => e
         ErrorResponse::Usage.new('message'=> e.to_s)
       rescue => e
        handle_error_in_wrapper(e)
      end
    end

    private

    def self.handle_error_in_wrapper(exception)
      error_hash =  {
        'message'=> exception.message,
        'backtrace' => exception.backtrace,
        'on_client' => true
      }
      
      if Config[:development_mode]
        Logger.instance.error_pp("Error inside wrapper DEV ONLY: #{exception.message}", exception.backtrace)
      end
      
      ErrorResponse::Internal.new(error_hash)
    end
  end
end

