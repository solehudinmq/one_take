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