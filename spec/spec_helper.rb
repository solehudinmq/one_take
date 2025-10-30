# frozen_string_literal: true

require "one_take"
require "byebug"
require "httparty"
require "dotenv"

Dotenv.load(".env", "spec/.env.test")

require_relative "../example/post"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
