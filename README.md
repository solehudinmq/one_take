# OneTake

One Take is a Ruby library for implementing idempotency in our backend systems. This means our systems now have the ability to produce an effect only once, even if the same operation is performed multiple times. This makes our systems more secure during retries and avoids the risk of duplicate data.

With the One Take library, our backend system will now be more secure, as if the client repeatedly sent the same request body, this is no longer a problem, as our backend system can now make operations idempotent, preventing duplicate data.

## High Flow

Potential problems if we do not implement idempotency when creating / retrying data :

![Logo Ruby](https://github.com/solehudinmq/one_take/blob/development/high_flow/One%20Take-problem.jpg)

With One Take, now the process of creating or retrying data will not cause duplicate data problems :

![Logo Ruby](https://github.com/solehudinmq/one_take/blob/development/high_flow/One%20Take-solution.jpg)

## Requirement

The minimum version of Ruby that must be installed is 3.0.

Requires dependencies to the following gems :
- uuidtools

- redis

- connection_pool

- dotenv (for the development/test environment)

## Installation

Add this line to your application's Gemfile :

```ruby
# Gemfile
gem 'one_take', git: 'git@github.com:solehudinmq/one_take.git', branch: 'main'
```

Open terminal, and run this :

```ruby
cd your_ruby_application
bundle install
```

## Environment Configuration

For 'development' or 'test' environments, make sure the '.env' file is in the root of your application :

```ruby
# .env
REDIS_URL=<redis-url>
LOCK_TIMEOUT=<lock-timeout>
CONNECTION_TIMEOUT_REDIS_POOL=<connection-timeout-redis-pool>
TOTAL_SIZE_REDIS_POOL=<total-size-redis-pool>
REDIS_EXPIRE=<redis-expire>
```

For more details, you can see the following example : [example/.env](https://github.com/solehudinmq/one_take/blob/development/example/.env).

## Usage

To use this library, add this to your code :

```ruby
require 'one_take'

idempotency = OneTake::Idempotency.new
result = idempotency.perform(idempotency_key: idempotency_key) do
  # create data
end
```

Parameter description :
- idempotency_key (required) : is the x-idempotency-key header sent from the frontend. Example : 

```bash
curl --location 'http://0.0.0.0:4567/posts' \
--header 'x-idempotency-key: abc-1' \
--header 'Content-Type: application/json' \
--data '{
    "title": "Post 1",
    "content": "Content post 1"
}'
```

## Example Implementation in Your Application

For examples of applications that use this gem, you can see them here : [example](https://github.com/solehudinmq/one_take/tree/development/example).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/solehudinmq/one_take.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
