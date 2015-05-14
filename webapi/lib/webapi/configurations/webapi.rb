# -*- coding: utf-8 -*-

require 'fuguta'

module Webapi
  module Configurations
    class Webapi < Fuguta::Configuration
      usual_paths [
                  ENV['CONF_PATH'].to_s,
                  '/etc/tiny-web-example/webapi.conf',
                  File.expand_path('config/webapi.conf', ::WEBAPI_ROOT)
                 ]

      param :database_uri

      def validate(errors)
        errors << "database_uri is undefined." unless @config[:database_uri]
      end
    end
  end
end
