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
  class ModuleRef

    attr_reader :namespace, :module_name, :version, :client_dir_path

    # opts can have keys
    #  :namespace
    #  :module_name
    #  :namespace_module_name
    #  :version
    #  :client_dir_path
    def initialize(opts = {})
      if opts[:namespace] and opts[:module_name]
        @namespace   = opts[:namespace]
        @module_name = opts[:module_name]
      elsif opts[:namespace_module_name]
        namespace, module_name =  NamespaceModuleName.parse(opts[:namespace_module_name])
        @namespace   = namespace
        @module_name = module_name
      else
        raise Error, "Either :module_name and :namespace must be given or :namespace_module_name"
      end
      @version         = opts[:version] 
      @client_dir_path = opts[:client_dir_path]
    end

    def pretty_print
      ::DTK::Common::PrettyPrintForm.module_ref(@module_name, :namespace => @namespace, :version => @version)
    end
    # TODO: look at deprecating print_form
    def print_form
      NamespaceModuleName.print_form(@namespace, @module_name, :version => @version)
    end

    MASTER_VERSION = 'master'
    def is_master_version?
      @version.nil? or @version == MASTER_VERSION
    end

    def same_module?(module_ref)
      @module_name == module_ref.module_name 
    end
      
    def exact_match?(module_ref)
      same_module?(module_ref) and @namespace == module_ref.namespace and @version == module_ref.version
    end


    private

    module NamespaceModuleName
      PRINT_FORM_DELIM = ':'
      PARSE_FORM_DELIM = [':', '/']

      # opts can have keys
      #   :version
      def self.print_form(namespace, module_name, opts = {}) 
        ret = "#{namespace}#{PRINT_FORM_DELIM}#{module_name}"
        if version = opts[:version]
          ret << "(#{version})" 
        end
        ret
      end

      def self.legal_form
        print_form('NAMESPACE', 'MODULE-NAME')
      end

      # returns [namespace, module_name] or raises error
      def self.parse(term)
        parse?(term) || raise(Error::Usage, illegal_term_msg(term))
      end

      private

      def self.parse?(term)
        if match_delim = PARSE_FORM_DELIM.find { |delim| term =~ Regexp.new(delim) }
          split = term.split(match_delim)
          if split.size == 2
            namespace   = split[0]
            module_name = split[1]
            [namespace, module_name]
          end
        end
      end

      def self.illegal_term_msg(term)
        # TODO: not showing how version can be in this
        "Illegal term '#{term}' for designating a module with a namespace; legal form is '#{legal_form}'"
      end
    end
  end
end
