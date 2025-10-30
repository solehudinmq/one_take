# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in one_take.gemspec
gemspec

gem "redis"
gem "connection_pool"
gem "uuidtools"

group :development, :test do
  gem "byebug"
  gem "dotenv"
end

group :development do
  gem "irb"
  gem "rake", "~> 13.0"
  gem "rubocop", "~> 1.21"
end

group :test do
  gem "rspec", "~> 3.0"
end