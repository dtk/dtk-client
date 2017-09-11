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
  class Operation::Service
    class Ssh < self
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          service_instance = args.required(:service_instance)
          node_name        = args.required(:node_name)
          remote_user      = args[:remote_user]

          if OsUtil.is_windows?
            OsUtil.print_info "[NOTICE] SSH functionality is currenly not supported on Windows."
            return
          end

          identity_file = get_identity_file(args[:identity_file])
          node_info     = get_node_info_for_ssh_login(node_name, service_instance)

          connect(node_info, identity_file, remote_user)
        end
      end

      private

      def self.get_identity_file(identity_file)
        if identity_file
          unless File.exists?(identity_file)
            raise Error::Usage, "Not able to find identity file, '#{identity_file}'"
          end
        elsif default_identity_file = OsUtil.dtk_identity_file_location
          if File.exists?(default_identity_file)
            identity_file = default_identity_file
          end
        end

        identity_file
      end

      def self.get_node_info_for_ssh_login(node_name, service_instance)
        info_hash = {}

        response = rest_get("#{BaseRoute}/#{service_instance}/nodes")
        unless node_info = response.data.find{ |node| node_name == node['display_name'] }
          raise Error::Usage, "The node '#{node_name}' does not exist"
        end

        if dns_address = node_info['dns_address']
          info_hash.merge!(:dns_address => dns_address)
        end

        if default_login_user = default_login_user?(node_info)
          info_hash.merge!(:default_login_user => default_login_user)
        end
pp info_hash
        info_hash
      end

      def self.default_login_user?(node_info)
        if os_type = node_info['os_type']
          DefaultLoginByOSType[os_type]
        end
      end

      DefaultLoginByOSType = {
        'ubuntu'       => 'ubuntu',
        'amazon-linux' => 'ec2-user'
      }

      def self.connect(node_info, identity_file, remote_user)
        unless dns_address = node_info[:dns_address]
          raise Error::Usage, "Not able to resolve instance address, has instance been stopped?"
        end

        unless remote_user ||= node_info[:default_login_user]
          raise Error::Usage, "A default Linux login user could not be computed. Retry the command with a specified login using the '-u LINUX-USER' option."
        end

        connection_string = "#{remote_user}@#{dns_address}"

        ssh_command =
          if identity_file
            # provided PEM key
            "ssh -o \"StrictHostKeyChecking no\" -o \"UserKnownHostsFile /dev/null\" -i #{identity_file} #{connection_string}"
          elsif SSHUtil.ssh_reachable?(remote_user, dns_address)
            # it has PUB key access
            "ssh -o \"StrictHostKeyChecking no\" -o \"UserKnownHostsFile /dev/null\" #{connection_string}"
          end

        unless ssh_command
          raise Error::Usage, "No public key access or PEM provided, please grant access or provide valid PEM key"
        end

        OsUtil.print_info("You are entering SSH terminal (#{connection_string}) ...")
        Kernel.system(ssh_command)
        OsUtil.print_info("You are leaving SSH terminal, and returning to DTK Shell ...")
      end

    end
  end
end
