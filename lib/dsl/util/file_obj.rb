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
  class FileObj
    # opts can have keys
    #  :path
    def initialize(opts = {})
      @path = opts[:path]
      @content   = get_content?(@path)
    end
    
    def content_or_raise_error
      @content || raise(Error::Usage, error_msg_no_content)
    end
    def content
      @content || raise(Error, 'Method should not be called if @content is nil')
    end
    def content?
      @content 
    end

    def raise_error_if_no_content
      raise(Error::Usage, error_msg_no_content) unless @content
      self
    end

    def exists?
      ! @content.nil?
    end

    def path?
      @path
    end

    private

    # These can be overwritten
    def file_path_type
      'file'
    end
    def dir_ref
      'directory'
    end

    ### 

    def error_msg_no_content
      if @path
        "No #{file_path_type} found at '#{@path}'"
      else
        "Cannot find #{file_path_type} in the #{dir_ref} or ones nested under it"
      end
    end
    
    def get_content?(path)
      File.open(path).read if path and File.exists?(path)
    end
  end
end
