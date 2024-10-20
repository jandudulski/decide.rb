# frozen_string_literal: true

require_relative "lib/decider/version"

Gem::Specification.new do |spec|
  github_uri = "https://github.com/jandudulski/decide.rb"

  spec.name = "decide.rb"
  spec.version = Decider::VERSION
  spec.authors = ["Jan Dudulski"]
  spec.email = ["jan@dudulski.pl"]

  spec.summary = "Functional Event Sourcing Decider in Ruby"
  spec.description = "Functional Event Sourcing Decider in Ruby"
  spec.homepage = github_uri
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["bug_tracker_uri"] = "#{github_uri}/issues"
  spec.metadata["changelog_uri"] = "#{github_uri}/CHANGELOG.md"
  spec.metadata["documentation_uri"] = github_uri
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = github_uri

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
