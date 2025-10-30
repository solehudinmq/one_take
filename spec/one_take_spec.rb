# frozen_string_literal: true

# run : 
# redis-server --port 6380
# bundle exec ruby app.rb
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
    result = HTTParty.post('http://localhost:4567/posts', 
      body: { title: "Post 1", content: "Content post 1" }.to_json,
      headers: { 'x-idempotency-key': 'abc-1', 'Content-Type' => 'application/json' },
      timeout: 3
    )   
      
    data = result['data']
    
    expect(result.code).to be(201)
    expect(data["title"]).to eq('Post 1')
    expect(data["content"]).to eq('Content post 1')

    # retry
    result2 = HTTParty.post('http://localhost:4567/posts', 
      body: { title: "Post 1", content: "Content post 1" }.to_json,
      headers: { 'x-idempotency-key': 'abc-1', 'Content-Type' => 'application/json' },
      timeout: 3
    )   
      
    data2 = result2['data']
    
    expect(result2.code).to be(201)
    expect(data2["title"]).to eq('Post 1')
    expect(data2["content"]).to eq('Content post 1')

    # check response id from both processes
    expect(data["id"]).to eq(data2["id"])
  end

  it "return failed, x-idempotency-key header not sent" do
    result = HTTParty.post('http://localhost:4567/posts', 
      body: { title: "Post 2", content: "Content post 2" }.to_json,
      headers: { 'Content-Type' => 'application/json' },
      timeout: 3
    )

    expect(result.code).to be(500)
    expect(result["error"]).to eq("header 'x-idempotency-key' is required to be sent.")
  end

  it "return failed, due to error when saving data" do
    result = HTTParty.post('http://localhost:4567/error_simulations', 
      body: { title: "Post 2", content: "Content post 2" }.to_json,
      headers: { 'x-idempotency-key': 'abc-2', 'Content-Type' => 'application/json' },
      timeout: 3
    )
    
    expect(result.code).to be(500)
    expect(result["error"]).to eq("Failed to lock : Failure occurred while saving data.")
  end
end
