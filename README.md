# Luosimao SMS Ruby SDK

[![Gem Version](https://img.shields.io/gem/v/luosimao-sms)](https://rubygems.org/gems/luosimao-sms)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A Ruby SDK for sending SMS via the [Luosimao](https://luosimao.com) API. Integrates seamlessly with your Ruby/Rails application.

[English](#english) | [中文](#chinese)

---

<a id="english"></a>
## English

### Installation

```bash
gem install luosimao-sms
```

Or add to your `Gemfile`:

```ruby
gem 'luosimao-sms'
```

### Quick Start

```ruby
require 'luosimao-sms'

client = Luosimao::SMS::Client.new(api_key: 'your_api_key')

# Send a single SMS
response = client.send(mobile: '13800138000', message: 'Verification code 123456【Your Company】')
puts response.success?

# Batch send
response = client.send_batch(
  mobiles: ['13800138000', '13800138001'],
  message: 'Notification content【Your Company】'
)

# Check balance
status = client.status
puts "Balance: #{status.deposit} messages"
```

### Configuration

```ruby
client = Luosimao::SMS::Client.new(
  api_key: 'your_api_key',          # Required. Auto-adds 'key-' prefix if omitted.
  timeout: 10,                      # Read timeout in seconds (default: 30).
  open_timeout: 5,                   # Connection timeout in seconds (default: 10).
  base_url: 'https://sms-api.luosimao.com'  # For testing purposes.
)
```

### API Reference

| Method | Description |
|--------|-------------|
| `client.send(mobile:, message:)` | Send a single SMS. Returns `Luosimao::SMS::Response`. |
| `client.send_batch(mobiles:, message:, send_at: nil)` | Batch send. `send_at` accepts a `Time` object for scheduled delivery. |
| `client.status` | Query account balance. Returns `Luosimao::SMS::StatusResponse`. |

### Error Handling

| Exception | Description | Helper Methods |
|-----------|-------------|----------------|
| `Luosimao::SMS::APIError` | API returned an error code. | `auth_failed?`, `insufficient_balance?`, `sensitive_words?`, `ip_not_allowed?` |
| `Luosimao::SMS::NetworkError` | Network failure (timeout, connection refused, invalid JSON). | - |
| `Luosimao::SMS::ArgumentError` | Invalid method arguments. | - |

Example:

```ruby
begin
  client.send(mobile: '13800138000', message: 'Verification code 123456【Company】')
rescue Luosimao::SMS::APIError => e
  puts "API Error [#{e.code}]: #{e.message}"
  puts "Insufficient balance!" if e.insufficient_balance?
rescue Luosimao::SMS::NetworkError => e
  puts "Network error: #{e.message}"
end
```

### Development

```bash
git clone https://github.com/luosimao-oss/luosimao-sms-ruby.git
cd luosimao-sms
bundle install
bundle exec rspec
```

### Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<a id="chinese"></a>
## 中文

螺丝帽 (Luosimao) 短信服务的 Ruby SDK。

### 安装

```bash
gem install luosimao-sms
```

或在 `Gemfile` 中添加：

```ruby
gem 'luosimao-sms'
```

### 快速开始

```ruby
require 'luosimao-sms'

client = Luosimao::SMS::Client.new(api_key: 'your_api_key')

# 单发短信
response = client.send(mobile: '13800138000', message: '验证码123456【你的公司】')
puts response.success?

# 批量发送
response = client.send_batch(
  mobiles: ['13800138000', '13800138001'],
  message: '活动通知【你的公司】'
)

# 查询余额
status = client.status
puts "当前余额：#{status.deposit} 条"
```

### 配置参数

```ruby
client = Luosimao::SMS::Client.new(
  api_key: 'your_api_key',        # 必填。未带 key- 前缀会自动补全。
  timeout: 10,                    # 读取超时，默认 30 秒。
  open_timeout: 5,                # 连接超时，默认 10 秒。
  base_url: 'https://sms-api.luosimao.com'  # 可用于测试环境。
)
```

### 接口说明

| 方法 | 说明 |
|------|------|
| `client.send(mobile:, message:)` | 单发短信。返回 `Luosimao::SMS::Response`。 |
| `client.send_batch(mobiles:, message:, send_at: nil)` | 批量发送。`send_at` 传入 `Time` 对象可定时发送。 |
| `client.status` | 查询账户余额。返回 `Luosimao::SMS::StatusResponse`。 |

### 异常处理

| 异常类 | 说明 | 帮助方法 |
|--------|------|----------|
| `Luosimao::SMS::APIError` | API 返回错误码。 | `auth_failed?`, `insufficient_balance?`, `sensitive_words?`, `ip_not_allowed?` |
| `Luosimao::SMS::NetworkError` | 网络异常（超时、连接拒绝、非法 JSON）。 | - |
| `Luosimao::SMS::ArgumentError` | 参数错误。 | - |

使用示例：

```ruby
begin
  client.send(mobile: '13800138000', message: '验证码123456【公司名】')
rescue Luosimao::SMS::APIError => e
  puts "接口错误 [#{e.code}]：#{e.message}"
  puts "余额不足！" if e.insufficient_balance?
rescue Luosimao::SMS::NetworkError => e
  puts "网络异常：#{e.message}"
end
```

### 本地开发

```bash
git clone https://github.com/luosimao-oss/luosimao-sms-ruby.git
cd luosimao-sms
bundle install
bundle exec rspec
```

### 贡献指南

欢迎提交 Issue 和 Pull Request！

### 开源协议

本项目遵循 MIT 协议，详见 [LICENSE](LICENSE)。
