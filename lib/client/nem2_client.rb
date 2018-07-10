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
  class Nem2Client
    def self.wrap_nem2_operation(&block)
      Operation.raise_error_if_notok_response do
        Response.new(Response::RestClientWrapper.json_parse_if_needed(block.call))
      end
    end

    def self.rest_get(url)
      wrap_nem2_operation do
        Response::RestClientWrapper.get_raw(nem2_rest_url(url))
      end
    end

    def self.rest_post(url, post_body)
      wrap_nem2_operation do
        Response::RestClientWrapper.post_raw(nem2_rest_url(url), post_body)
      end
    end

    def self.nem2_rest_url(route = nil)
      "#{nem2_rest_url_base}/#{route}"
    end

    def self.nem2_rest_url_base
      @@nem2_rest_url_base ||= get_nem2_rest_url_base
    end

    def self.get_nem2_rest_url_base
      Config[:nem2_client_url] || 'http://localhost:3003'
    end
  end
end

