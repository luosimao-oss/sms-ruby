lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "luosimao/sms/version"

Gem::Specification.new do |spec|
  spec.name          = "luosimao-sms"
  spec.version       = Luosimao::SMS::VERSION
  spec.authors       = ["luosimao-oss"]
  spec.email         = ["luosimao-oss@example.com"]
  spec.summary       = "Ruby SDK for Luosimao SMS API"
  spec.description   = "A Ruby gem for sending SMS via Luosimao (螺丝帽) API"
  spec.homepage      = "https://github.com/luosimao-oss/luosimao-sms-ruby"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7.0"
  spec.files         = Dir["lib/**/*", "README.md", "LICENSE", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  # 开发依赖
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "webmock", "~> 3.18"
  spec.add_development_dependency "rake", "~> 13.0"
end
