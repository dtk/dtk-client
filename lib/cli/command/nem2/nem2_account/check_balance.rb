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
  module CLI::Command
    module Nem2Account
      subcommand_def 'check-balance' do |c|
        command_body c, 'check-balance', 'Check balance of nem2 account' do |sc|
          sc.flag Token.nem2_profile_address
          sc.action do |_global_options, options, args|
            Operation::Nem2::Account.check_balance
          end
        end
      end

    end
  end
end
