# -*- coding: utf-8 -*-

require 'logger'

module Helpers
  module Logger
    class CustomLogger
      attr_reader :logger

      def initialize(progname)
        @progname = progname
      end

      ["fatal", "error", "warn", "info", "debug"].each do |level|
        define_method(level) { |msg|
          logger.__send__(level, "#{msg}")
        }
      end
      alias :warning :warn

      def logger
        l = ::Logger.new(::Logger::LogDevice.new($>))
        l.progname = @progname
        l
      end

    end

    def self.included(klass)
      klass.class_eval {

        @class_logger = CustomLogger.new(self.to_s.split('::').last)

        def self.logger
          @class_logger
        end

        def logger
          self.class.logger
        end

        def self.logger_name
          @class_logger.progname
        end

        def self.logger_name=(name)
          @class_logger.progname = name
        end
      }
    end

  end
end
