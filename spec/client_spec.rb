require "spec_helper"

RSpec.describe Luosimao::SMS::Client do
  let(:api_key) { "test_api_key" }
  let(:client) { described_class.new(api_key: api_key) }

  describe "#initialize" do
    it "adds 'key-' prefix to api_key if missing" do
      expect(client.api_key).to eq("key-test_api_key")
    end

    it "does not add 'key-' prefix if already present" do
      c = described_class.new(api_key: "key-existing_key")
      expect(c.api_key).to eq("key-existing_key")
    end
  end

  describe "#send" do
    let(:url) { "https://sms-api.luosimao.com/v1/send.json" }

    it "sends a single SMS successfully" do
      stub_request(:post, url)
        .with(
          basic_auth: ["api", "key-test_api_key"],
          body: { "mobile" => "13800138000", "message" => "验证码123456【公司名】" }
        )
        .to_return(status: 200, body: fixture("send_success.json"))

      response = client.send(mobile: "13800138000", message: "验证码123456【公司名】")
      expect(response).to be_success
      expect(response.error_code).to eq(0)
    end

    it "raises ArgumentError when mobile is missing" do
      expect { client.send(mobile: "", message: "msg") }.to raise_error(Luosimao::SMS::ArgumentError)
    end

    it "handles API errors (e.g. auth failed)" do
      stub_request(:post, url)
        .to_return(status: 200, body: fixture("error_auth.json"))

      expect {
        client.send(mobile: "13800138000", message: "msg")
      }.to raise_error(Luosimao::SMS::APIError) do |error|
        expect(error.code).to eq(-10)
        expect(error.auth_failed?).to be true
      end
    end

    it "handles HTTP 500 errors" do
      stub_request(:post, url).to_return(status: 500, body: "Internal Server Error")

      expect {
        client.send(mobile: "13800138000", message: "msg")
      }.to raise_error(Luosimao::SMS::NetworkError, /HTTP 500/)
    end

    it "handles JSON parse errors" do
      stub_request(:post, url).to_return(status: 200, body: "<html>Not JSON</html>")

      expect {
        client.send(mobile: "13800138000", message: "msg")
      }.to raise_error(Luosimao::SMS::NetworkError, /Invalid JSON response/)
    end

    it "handles network timeouts" do
      stub_request(:post, url).to_timeout

      expect {
        client.send(mobile: "13800138000", message: "msg")
      }.to raise_error(Luosimao::SMS::NetworkError)
    end
  end

  describe "#send_batch" do
    let(:url) { "https://sms-api.luosimao.com/v1/send_batch.json" }

    it "sends a batch SMS successfully" do
      stub_request(:post, url)
        .with(
          basic_auth: ["api", "key-test_api_key"],
          body: { "mobile_list" => "13800138000,13800138001", "message" => "通知内容【公司名】" }
        )
        .to_return(status: 200, body: fixture("send_batch_success.json"))

      response = client.send_batch(mobiles: ["13800138000", "13800138001"], message: "通知内容【公司名】")
      expect(response).to be_success
    end

    it "raises ArgumentError when mobiles array is empty" do
      expect { client.send_batch(mobiles: [], message: "msg") }.to raise_error(Luosimao::SMS::ArgumentError)
    end

    it "raises ArgumentError when mobiles is not an array" do
      expect { client.send_batch(mobiles: "13800138000", message: "msg") }.to raise_error(Luosimao::SMS::ArgumentError)
    end

    it "sends a batch SMS with send_at successfully" do
      time = Time.new(2026, 5, 1, 12, 0, 0)
      stub_request(:post, url)
        .with(
          body: hash_including("time" => "2026-05-01 12:00:00")
        )
        .to_return(status: 200, body: fixture("send_batch_success.json"))

      response = client.send_batch(mobiles: ["138"], message: "msg", send_at: time)
      expect(response).to be_success
    end
  end

  describe "#status" do
    let(:url) { "https://sms-api.luosimao.com/v1/status.json" }

    it "queries status successfully" do
      stub_request(:get, url)
        .with(basic_auth: ["api", "key-test_api_key"])
        .to_return(status: 200, body: fixture("status_success.json"))

      response = client.status
      expect(response).to be_success
      expect(response.deposit).to eq(100.0)
    end
  end
end
