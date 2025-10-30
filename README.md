# OneTake

One Take is a Ruby library for implementing idempotency in our backend systems. This means our systems now have the ability to produce an effect only once, even if the same operation is performed multiple times. This makes our systems more secure during retries and avoids the risk of duplicate data.

With the One Take library, our backend system will now be more secure, as if the client repeatedly sent the same request body, this is no longer a problem, as our backend system can now make operations idempotent, preventing duplicate data.

## High Flow

Potential problems if we do not implement idempotency when creating / retrying data :
![Logo Ruby](https://github.com/solehudinmq/one_take/blob/development/high_flow/One%20Take-problem.jpg)

With One Take, now the process of creating or retrying data will not cause duplicate data problems :
![Logo Ruby](https://github.com/solehudinmq/one_take/blob/development/high_flow/One%20Take-solution.jpg)

## Installation

The minimum version of Ruby that must be installed is 3.0. Install gem 'redis', 'uuidtools' and 'dotenv' (for in development and test environments).

Add this line to your application's Gemfile :
```ruby
gem 'one_take', git: 'git@github.com:solehudinmq/one_take.git', branch: 'main'
```

Open terminal, and run this :
```ruby
cd your_ruby_application
bundle install
```

Create an '.env' file (for development/test environment) :
```ruby
# .env

REDIS_URL=<redis-url>
LOCK_TIMEOUT=<lock-timeout>
CONNECTION_TIMEOUT_REDIS_POOL=<connection-timeout-redis-pool>
TOTAL_SIZE_REDIS_POOL=<total-size-redis-pool>
REDIS_EXPIRE=<redis-expire>
```

Example : 
```ruby
# .env

REDIS_URL=redis://localhost:6379
LOCK_TIMEOUT=10
CONNECTION_TIMEOUT_REDIS_POOL=3
TOTAL_SIZE_REDIS_POOL=5
REDIS_EXPIRE=60
```

## Usage

To use this library, add this to your code :
```ruby
require 'one_take'

idempotency = OneTake::Idempotency.new
result = idempotency.perform(idempotency_key: idempotency_key) do
  # create data
end
```

The following is an example of use in the application :
```ruby
# Gemfile

source "https://rubygems.org"

gem "byebug"
gem "sinatra"
gem "activerecord"
gem "sqlite3"
gem "httparty"
gem "dotenv", groups: [:development, :test]
gem "one_take", git: "git@github.com:solehudinmq/one_take.git", branch: "main"
gem "rackup", "~> 2.2"
gem "puma", "~> 7.1"
```

```ruby
# post.rb

require 'sinatra'
require 'active_record'
require 'byebug'

# Configure database connections
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'db/development.sqlite3'
)

# Create a db directory if it doesn't exist yet
Dir.mkdir('db') unless File.directory?('db')

# Model
class Post < ActiveRecord::Base
  validates :title, presence: true
end

# Migration to create posts table
ActiveRecord::Schema.define do
  unless ActiveRecord::Base.connection.table_exists?(:posts)
    create_table :posts do |t|
      t.string :title
      t.string :content
      t.timestamps
    end
  end
end
```

```ruby
# app.rb
require 'sinatra'
require 'json'
require 'byebug'
require_relative 'post'
require 'one_take'

before do
  content_type :json
end

# create data post
post '/posts' do
  begin
    idempotency_key = request.env['HTTP_X_IDEMPOTENCY_KEY']
    
    idempotency = OneTake::Idempotency.new
    result = idempotency.perform(idempotency_key: idempotency_key) do
      request_body = JSON.parse(request.body.read)
      post = Post.create(title: request_body["title"], content: request_body["content"])

      post
    end
    
    status 201
    return { data: JSON.parse(result['data']), message: result['status'] }.to_json
  rescue => e
    status 500
    return { error: e.message }.to_json
  end
end

# error simulations
post '/error_simulations' do
  begin
    idempotency_key = request.env['HTTP_X_IDEMPOTENCY_KEY']

    idempotency = OneTake::Idempotency.new
    result = idempotency.perform(idempotency_key: idempotency_key) do
      request_body = JSON.parse(request.body.read)
      post = Post.create(title: nil, content: request_body["content"])

      post
    end
    
    status 201
    return { data: JSON.parse(result['data']), message: result['status'] }.to_json
  rescue => e
    status 500
    return { error: e.message }.to_json
  end
end

# open terminal
# cd your_project
# bundle install
# bundle exec ruby app.rb
# 1. success scenario
# curl --location 'http://0.0.0.0:4567/posts' \
# --header 'x-idempotency-key: abc-1' \
# --header 'Content-Type: application/json' \
# --data '{
#     "title": "Post 1",
#     "content": "Content post 1"
# }'
# 2. fail scenarion
# curl --location 'http://0.0.0.0:4567/error_simulations' \
# --header 'x-idempotency-key: abc-2' \
# --header 'Content-Type: application/json' \
# --data '{
#     "title": "Post 2",
#     "content": "Content post 2"
# }'
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/solehudinmq/one_take.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
