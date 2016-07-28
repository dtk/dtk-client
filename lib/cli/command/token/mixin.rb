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
  class CLI::Command::Token
    module Mixin
      attr_reader :key
      def initialize(key, hash = {})
        super()
        replace(hash)
        @key = key
      end

      # Each concrete class must define
      # def ref - returns string
      # end
      # def token_type - symbol
      # end

      def add_overrides(overrides)
        merge(overrides)
      end

    end
  end
end
