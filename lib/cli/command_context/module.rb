module DTK::CLI
  class CommandContext
    class Module < self
    end

    private

    def add_command_defs__module!
      desc 'Describe some switch here'
      switch [:s,:switch]
      
      desc 'Describe some flag here'
      default_value 'the default'
      arg_name 'The name of the argument'
      flag [:f,:flagname]
      
      desc 'Describe module here'
      arg_name 'Describe arguments to module here'
      command :module do |c|
        c.desc 'Describe a switch to module'
        c.switch :s
        
        c.desc 'Describe a flag to module'
        c.default_value 'default'
        c.flag :f
        c.action do |global_options, options, args|
          
          # Your command logic here
          
          # If you have any errors, just raise them
          # raise "that command made no sense"
          pp [global_options, options, args]
          puts "module command ran"
        end
      end
    end
  end
end


