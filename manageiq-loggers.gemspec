
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "manageiq/loggers/version"
require "rbconfig"

Gem::Specification.new do |spec|
  spec.name          = "manageiq-loggers"
  spec.version       = ManageIQ::Loggers::VERSION
  spec.authors       = ["ManageIQ Authors"]

  spec.summary       = %q{Loggers for ManageIQ projects}
  spec.homepage      = "https://github.com/ManageIQ/manageiq-loggers"
  spec.licenses      = ["Apache-2.0"]

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport",     ">= 5.0"
  spec.add_runtime_dependency "manageiq-password", "~> 0.1"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "cloudwatchlogger"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "systemd-journal" if RbConfig::CONFIG['host_os'] =~ /linux/i
end
