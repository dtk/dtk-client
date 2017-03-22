#!/usr/bin/env ruby
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
require 'pp'
unless service_name = ARGV[0] 
  puts "Usage: api-test SERVICE-NAME"
  exit 1
end

require_relative '../lib/dtk_client'

args = {
  :module_namespace => 'scale15-lab', 
  :module_name      => 'workshop',
  :module_version   => '0.5.0',
  :service_name     => service_name
}
include DTK::Client

post_body = PostBody.new(
  :namespace       => args[:module_namespace],
  :module_name     => args[:module_name],
  :version?        => args[:module_version],
  :service_name    => args[:service_name]
)

# require 'byebug'; byebug

response = Session.rest_post('modules/stage', post_body)
pp response
exit 0
=begin
To delete a service SERVICE-NAME; issue:
dtk service uninstall -y --delete -n SERVICE-NAME
=end
