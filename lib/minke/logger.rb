module Minke
  class Logging
    @@debug = false
    @@ret = "\n"
    
    def self.create_logger verbose = false
      Logger.new(STDOUT).tap do |l|
        l.datetime_format = ''
        l.formatter = proc do |severity, datetime, progname, msg|
          case severity
          when 'ERROR'
            s = "#{@@ret if @@debug}#{'ERROR'.colorize(:red)}: #{msg.chomp('')}\n"
            @@debug = false
            s
          when 'INFO'
            s = "#{@@ret if @@debug}#{'INFO'.colorize(:green)}: #{msg.chomp('')}\n"
            @@debug = false
            s
          when 'DEBUG'
            if verbose == true
              "#{'DEBUG'.colorize(:yellow)}: #{msg.chomp('')}\n"
            else
              @@debug = true
              "#{'.'.colorize(:yellow)}"
            end
          end
        end
      end
    end
  end
end
