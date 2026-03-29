module Luosimao
  module SMS
    class Client
      attr_reader :api_key, :timeout, :open_timeout, :base_url

      def initialize(api_key:, timeout: 30, open_timeout: 10, base_url: "https://sms-api.luosimao.com")
        @api_key = api_key.to_s.start_with?("key-") ? api_key.to_s : "key-#{api_key}"
        @timeout = timeout
        @open_timeout = open_timeout
        @base_url = base_url.chomp("/")
      end

      # 单发短信
      # @param mobile [String] 手机号
      # @param message [String] 短信内容（含签名）
      # @return [Luosimao::SMS::Response]
      # @raise [Luosimao::SMS::APIError, Luosimao::SMS::NetworkError, Luosimao::SMS::ArgumentError]
      def send(mobile:, message:)
        raise Luosimao::SMS::ArgumentError, "mobile is required" if mobile.nil? || mobile.empty?
        raise Luosimao::SMS::ArgumentError, "message is required" if message.nil? || message.empty?

        response = request(
          method: :post,
          path: "/v1/send.json",
          form_data: {
            "mobile" => mobile,
            "message" => message
          }
        )

        handle_response(response, Response)
      end

      # 批量发送
      # @param mobiles [Array<String>] 手机号数组
      # @param message [String] 短信内容
      # @param send_at [Time, nil] 定时发送时间（可选）
      # @return [Luosimao::SMS::Response]
      def send_batch(mobiles:, message:, send_at: nil)
        raise Luosimao::SMS::ArgumentError, "mobiles array must be a non-empty array" unless mobiles.is_a?(Array) && !mobiles.empty?
        raise Luosimao::SMS::ArgumentError, "message is required" if message.nil? || message.empty?

        form_data = {
          "mobile_list" => mobiles.join(","),
          "message" => message
        }
        form_data["time"] = send_at.strftime("%Y-%m-%d %H:%M:%S") if send_at

        response = request(
          method: :post,
          path: "/v1/send_batch.json",
          form_data: form_data
        )

        handle_response(response, Response)
      end

      # 查询余额
      # @return [Luosimao::SMS::StatusResponse]
      def status
        response = request(
          method: :get,
          path: "/v1/status.json"
        )

        handle_response(response, StatusResponse)
      end

      private

      def request(method:, path:, form_data: nil)
        uri = URI.parse("#{@base_url}#{path}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == "https")
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER if http.use_ssl?
        http.read_timeout = @timeout
        http.open_timeout = @open_timeout

        req = case method
              when :get
                Net::HTTP::Get.new(uri.request_uri)
              when :post
                Net::HTTP::Post.new(uri.request_uri)
              else
                raise Luosimao::SMS::ArgumentError, "unsupported method \#{method}"
              end

        req.basic_auth("api", @api_key)

        if method == :post && form_data
          req.set_form_data(form_data)
        end

        begin
          http.request(req)
        rescue Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNREFUSED, SocketError => e
          raise Luosimao::SMS::NetworkError, e.message
        end
      end

      def handle_response(http_response, response_class)
        unless http_response.code.to_i.between?(200, 299)
          raise Luosimao::SMS::NetworkError, "HTTP #{http_response.code}: #{http_response.message}"
        end

        begin
          body = JSON.parse(http_response.body)
        rescue JSON::ParserError => e
          body_preview = http_response.body ? http_response.body[0..200] : ""
          raise Luosimao::SMS::NetworkError, "Invalid JSON response: #{e.message}. Body: #{body_preview}"
        end

        resp = response_class.new(body, http_response.code.to_i)
        if resp.success?
          resp
        else
          raise Luosimao::SMS::APIError.new(code: resp.error_code, message: resp.message)
        end
      end
    end
  end
end
