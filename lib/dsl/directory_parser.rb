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

module DTK::DSL; 
  class DirectoryParser
    # Types of directory parsers
    require_relative('directory_parser/git')
    require_relative('directory_parser/file_system')

    require_relative('directory_parser/path_info')

    #### Abstract methods 

    # returns an array of strings that are file paths
    def matching_file_paths(path_info)
      raise Error::NoMethodForConcreteClass.new(self.class)
    end

    # return either a string file path or of match to path_info working from current directory and 'otwards'
    # until base_path in path_info (if it exists)
    # opts can have keys
    #  :current_dir if set means start from this dir; otherwise start from computed current dir
    def most_nested_matching_file_path?(path_info, opts = {})
      raise Error::NoMethodForConcreteClass.new(self.class)
    end
    ##### End Abstract methods
  end
end
