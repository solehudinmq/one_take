# frozen_string_literal: true

require_relative "lib/one_take/version"

Gem::Specification.new do |spec|
  spec.name = "one_take"
  spec.version = OneTake::VERSION
  spec.authors = ["SolehMQ"]
  spec.email = ["solehudinmq@gmail.com"]

  spec.summary = "One Take is a Ruby library for implementing idempotency in our backend systems. This means our systems now have the ability to produce an effect only once, even if the same operation is performed multiple times. This makes our systems more secure during retries and avoids the risk of duplicate data."
  spec.description = "With the One Take library, our backend system will now be more secure, as if the client repeatedly sent the same request body, this is no longer a problem, as our backend system can now make operations idempotent, preventing duplicate data."
  spec.homepage = "TODO: Put your gem's website or public repo URL here."
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "dotenv", "~> 3.1"
  spec.add_dependency "uuidtools", "~> 3.0"
  spec.add_dependency "redis", "~> 5.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
