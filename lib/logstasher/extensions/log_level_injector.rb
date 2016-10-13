require 'logstasher/levels'

module LogStasher
  module Extensions
    module LogLevelInjector
      def inject_log_level(event_name, log_level)
        self.class_eval <<-CODE
            def #{event_name}_with_log_level(event)
              log_level = event.payload[:exception] ? ::LogStasher::Levels::ERROR : '#{log_level}'
              event.payload[:loglevel] = log_level
              #{event_name}_without_log_level(event)
            end
            alias_method :#{event_name}_without_log_level, :#{event_name}
            alias_method :#{event_name}, :#{event_name}_with_log_level
        CODE
      end
    end
  end
end
