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
    
    idempotency_process = OneTake::Idempotency.new

    result = idempotency_process.perform(idempotency_key: idempotency_key) do
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

# open terminal
# cd your_project
# bundle install
# bundle exec ruby app.rb
# 1. success scenario
# curl --location 'http://localhost:4567/posts' \
# --header 'Content-Type: application/json' \
# --data '{
#     "title": "Post 1",
#     "content": "Content 1"
# }'