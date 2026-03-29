# 如果是通过 gem install 安装的，可以直接 require "luosimao-sms"
# 这里的 $LOAD_PATH 操作仅为了在本地开发时直接运行此文件
$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))
require "luosimao-sms"

client = Luosimao::SMS::Client.new(
  api_key: "your_api_key",
  timeout: 10
)

# 单发短信
begin
  resp = client.send(mobile: "13800138000", message: "验证码：123456【你的公司】")
  puts "发送成功！余额: \#{resp.raw}" if resp.success?
rescue Luosimao::SMS::APIError => e
  if e.insufficient_balance?
    puts "余额不足，请充值"
  elsif e.auth_failed?
    puts "API Key 错误"
  else
    puts "发送失败：[\#{e.code}] \#{e.message}"
  end
rescue Luosimao::SMS::NetworkError => e
  puts "网络异常：\#{e.message}"
end

# 批量发送
begin
  resp = client.send_batch(
    mobiles: ["13800138000", "13800138001"],
    message: "活动通知内容【你的公司】"
  )
  puts "批量发送成功" if resp.success?
rescue Luosimao::SMS::Error => e
  puts "批量发送异常: \#{e.message}"
end

# 定时发送
begin
  resp = client.send_batch(
    mobiles: ["13800138000"],
    message: "定时通知【你的公司】",
    send_at: Time.new(2026, 5, 1, 12, 0, 0)
  )
  puts "定时发送成功" if resp.success?
rescue Luosimao::SMS::Error => e
  puts "定时发送异常: \#{e.message}"
end

# 查询余额
begin
  status = client.status
  puts "当前余额：\#{status.deposit} 条"
rescue Luosimao::SMS::Error => e
  puts "查询余额异常: \#{e.message}"
end
