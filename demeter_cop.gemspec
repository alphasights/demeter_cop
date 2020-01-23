lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "demeter_cop/version"

Gem::Specification.new do |spec|
  spec.name          = "demeter_cop"
  spec.version       = DemeterCop::VERSION
  spec.authors       = ["Madis Nõmme"]
  spec.email         = ["contact@mad.is"]

  spec.summary       = %q{Discover Law of Demeter violations on Ruby objects}
  spec.description   = %q{Allows to watch any object and record method chain call locations during runtime}
  spec.homepage      = "https://github.com/alphasights/demeter_cop"
  spec.license       = "MIT"

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/alphasights/demeter_cop"
  spec.metadata["changelog_uri"] = "https://github.com/alphasights/demeter_cop/blob/master/CHANGELOG"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec_junit_formatter", "~> 0.4"
end
