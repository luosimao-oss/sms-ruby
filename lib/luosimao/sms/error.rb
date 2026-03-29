module Luosimao
  module SMS
    # 基础异常
    class Error < StandardError; end

    # API 返回错误
    class APIError < Error
      attr_reader :code

      def initialize(code:, message:)
        @code = code.to_i
        super(message)
      end

      def auth_failed?
        @code == -10
      end

      def insufficient_balance?
        @code == -20
      end

      def sensitive_words?
        @code == -30 || @code == -31
      end

      def ip_not_allowed?
        @code == -50
      end
    end

    # 网络请求异常
    class NetworkError < Error; end

    # 参数校验异常
    class ArgumentError < Error; end
  end
end
