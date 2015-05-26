# -*- coding: utf-8 -*-

module WebAPIClient
  module ResponseFormats
    def self.[](format)
      case format
      when :json
        Json.new
      else
        rase "Unknown response format: #{format}"
      end
    end

    class Format
      def parse(response)
        raise NotImplementedError
      end
    end

    class Json < Format
      def parse(response)
        JSON.parse(response.body) unless response.body.empty?
      end
    end
  end
end
