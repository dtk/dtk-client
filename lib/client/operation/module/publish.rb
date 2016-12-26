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
  class Operation::Module
    class Publish < self
      def initialize(catalog, module_ref, directory_path)
        @catalog           = catalog
        @module_ref        = module_ref
        @target_repo_dir   = directory_path || OsUtil.current_dir
      end
      private :initialize

      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          module_ref        = args.required(:module_ref)
          directory_path    = args[:directory_path]
          new('dtkn', module_ref, directory_path).publish
        end
      end
      
      def publish
        unless module_version_exists?(module_ref, :type => :common_module)
          raise Error::Usage, "Module #{module_ref.print_form} does not exist on server"
        end

        error_msg = "To allow publish to go through, invoke 'dtk push' to push the changes to server before invoking publish again"
        DTK::Client::GitRepo.modified_with_diff?(target_repo_dir, { :error_msg => error_msg })

        post_body = PostBody.new(
          :module_name => module_ref.module_name,
          :namespace   => module_ref.namespace,
          :version     => module_ref.version,
          :rsa_pub_key => SSHUtil.rsa_pub_key_content
        )

        response = rest_post "#{BaseRoute}/publish_to_remote", post_body
        nil
      end

      private
      attr_reader :module_ref, :target_repo_dir

    end
  end
end


