require 'active_support/core_ext/class/attribute'
require 'active_support/log_subscriber'

module LogStasher
  module ActiveSupport
    class MailerLogSubscriber < ::ActiveSupport::LogSubscriber
      extend LogStasher::Extensions::LogLevelInjector

      MAILER_FIELDS = [:mailer, :action, :message_id, :from, :to, :loglevel]

      def deliver(event)
        process_event(event, ['mailer', 'deliver'])
      end

      def receive(event)
        process_event(event, ['mailer', 'receive'])
      end

      def process(event)
        process_event(event, ['mailer', 'process'])
      end

      inject_log_level :deliver, ::LogStasher::Levels::INFO
      inject_log_level :receive, ::LogStasher::Levels::INFO
      inject_log_level :process, ::LogStasher::Levels::INFO

      def logger
        LogStasher.logger
      end

      private

      def process_event(event, tags)
        data = LogStasher.request_context.merge(extract_metadata(event.payload))
        logger << LogStasher.build_logstash_event(data, tags).to_json + "\n"
      end

      def extract_metadata(payload)
        payload.slice(*MAILER_FIELDS)
      end
    end
  end
end
