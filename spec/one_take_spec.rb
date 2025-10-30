# frozen_string_literal: true

# run : 
# redis-server --port 6380
RSpec.describe OneTake do
  before(:all) do
    Post.delete_all

    redis = Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6380')
    redis.flushdb
  end

  it "has a version number" do
    expect(OneTake::VERSION).not_to be nil
  end

  it "return successful, when retrying the data is not duplicated" do
    idempotency_key = 'abc-1'

    idempotency = OneTake::Idempotency.new
    result = idempotency.perform(idempotency_key: idempotency_key) do
      post = Post.create(title: 'Post 1', content: 'Content post 1')

      post
    end
    
    data = JSON.parse(result['data'])

    expect(data["title"]).to eq('Post 1')
    expect(data["content"]).to eq('Content post 1')

    # retry
    result2 = idempotency.perform(idempotency_key: idempotency_key) do
      post = Post.create(title: 'Post 1', content: 'Content post 1')

      post
    end
    
    data2 = JSON.parse(result2['data'])

    expect(data2["title"]).to eq('Post 1')
    expect(data2["content"]).to eq('Content post 1')

    # check response id from both processes
    expect(data["id"]).to eq(data2["id"])
  end

  it "return failed, x-idempotency-key header not sent" do
    begin
      idempotency_key = nil

      idempotency = OneTake::Idempotency.new
      result = idempotency.perform(idempotency_key: idempotency_key) do
        post = Post.create(title: 'Post 2', content: 'Content post 2')

        post
      end
    rescue => e
      expect(e.message).to eq("header 'x-idempotency-key' is required to be sent.")
    end
  end

  it "return failed, due to error when saving data" do
    begin
      idempotency_key = 'abc-1'

      idempotency = OneTake::Idempotency.new
      result = idempotency.perform(idempotency_key: idempotency_key) do
        post = Post.create(title: nil, content: 'Content post 1')

        post
      end
    rescue => e
      expect(e.message).to eq("Failed to lock : Failure occurred while saving data.")
    end
  end
end
