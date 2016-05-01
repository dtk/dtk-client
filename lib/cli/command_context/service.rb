module DTK::CLI
  class CommandContext
    class Service < self
    end

    private
      
    def add_command_defs__service!
      desc 'Describe service here'
      arg_name 'Describe arguments to service here'
      command :service do |c|
        c.desc 'Describe a switch to service'
        c.switch :s
        
        c.desc 'Describe a flag to service'
        c.default_value 'default'
        c.flag :f
        c.action do |global_options, options, args|
          
          # Your command logic here
          
          # If you have any errors, just raise them
          # raise "that command made no sense"
          pp [global_options, options, args]
          puts "service command ran"
        end
      end
    end
  end
end

