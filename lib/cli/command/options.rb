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
  module CLI
    module Command
      class Options
        attr_reader :opts_hash

        def initialize(opts_hash)
          @opts_hash = opts_hash
        end
        
        def [](canonical_name_or_opt)
          key = Token.opt?(canonical_name_or_opt) || canonical_name_or_opt
          # TODO: check why this switch to below was needed was needed
          #@opts_hash[key]
          case key
          when ::String, ::Symbol
            @opts_hash[key]
          when ::Array
            if matching_key = key.find { |k| @opts_hash.has_key?(k) }
              @opts_hash[matching_key]
            end
          else
            raise Eroor, "Unexpected value of key.class: #{key.class}"
          end
        end

      end
    end
  end
end
