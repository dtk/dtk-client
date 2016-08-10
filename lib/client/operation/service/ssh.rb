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
            fail Error::Usage, "Not able to find identity file, '#{identity_file}'"
          end
        elsif default_identity_file = OsUtil.dtk_identity_file_location
          if File.exists?(default_identity_file)
            identity_file = default_identity_file
          end
        end

        identity_file
      end

      def self.get_node_info_for_ssh_login(node_name, service_instance)
        # TODO: use another route since want to deprecate "#{BaseRoute}/#{service_instance}"
        response = rest_get("#{BaseRoute}/#{service_instance}")

        unless node_info = response.data(:nodes).find{ |node| node_name == node['display_name'] }
          raise Error::Usage, "Cannot find info about node with id '#{node_id}'"
        end

        data            = {}
        node_properties = node_info['node_properties'] || {}

        if public_dns = node_properties['ec2_public_address']
          data.merge!(:public_dns => public_dns)
        end

        if default_login_user = default_login_user?(node_properties)
          data.merge!(:default_login_user => default_login_user)
        end

        data
      end

      def self.default_login_user?(node_properties)
        if os_type = node_properties['os_type']
          DefaultLoginByOSType[os_type]
        end
      end

      DefaultLoginByOSType = {
        'ubuntu'       => 'ubuntu',
        'amazon-linux' => 'ec2-user'
      }

      def self.connect(node_info, identity_file, remote_user)
        unless public_dns = node_info[:public_dns]
          raise Error::Usage, "Not able to resolve instance address, has instance been stopped?"
        end

        unless remote_user ||= node_info[:default_login_user]
          raise Error::Usage, "Retry command with a specfic login user (a default login user could not be computed)"
        end

        connection_string = "#{remote_user}@#{public_dns}"

        ssh_command =
          if identity_file
            # provided PEM key
            "ssh -o \"StrictHostKeyChecking no\" -o \"UserKnownHostsFile /dev/null\" -i #{identity_file} #{connection_string}"
          elsif SSHUtil.ssh_reachable?(remote_user, public_dns)
            # it has PUB key access
            "ssh -o \"StrictHostKeyChecking no\" -o \"UserKnownHostsFile /dev/null\" #{connection_string}"
          end

        unless ssh_command
          raise Error::Usage, "No public key access or PEM provided, please grant access or provide valid PEM key"
        end

        OsUtil.print("You are entering SSH terminal (#{connection_string}) ...", :yellow)
        Kernel.system(ssh_command)
        OsUtil.print("You are leaving SSH terminal, and returning to DTK Shell ...", :yellow)
      end

    end
  end
end
