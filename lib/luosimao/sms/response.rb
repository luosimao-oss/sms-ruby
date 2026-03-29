module Luosimao
  module SMS
    class Response
      attr_reader :raw, :http_code

      def initialize(raw, http_code = 200)
        @raw = raw || {}
        @http_code = http_code
      end

      def success?
        error_code == 0
      end

      def error_code
        @raw["error"].to_i
      end

      def message
        @raw["msg"] || ""
      end
    end

    class StatusResponse < Response
      def deposit
        if @raw["result"] && @raw["result"]["deposit"]
          @raw["result"]["deposit"].to_f
        else
          0.0
        end
      end
    end
  end
end
