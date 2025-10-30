# frozen_string_literal: true

require_relative "one_take/version"
require "uuidtools"
require "redis"
require "connection_pool"
require "dotenv/load" # only for development and test env

module OneTake
  class Idempotency
    IDEMPOTENCY_KEY_PREFIX = "idempotency:".freeze
    LOCK_KEY_PREFIX = "lock:".freeze
    REDIS_URL = (ENV['REDIS_URL'] || 'redis://localhost:6379').freeze
    LOCK_TIMEOUT = (ENV['LOCK_TIMEOUT'] || 30).to_i.freeze
    CONNECTION_TIMEOUT_REDIS_POOL = (ENV['CONNECTION_TIMEOUT_REDIS_POOL'] || 5).to_i.freeze
    TOTAL_SIZE_REDIS_POOL = (ENV['TOTAL_SIZE_REDIS_POOL'] || 10).to_i.freeze
    REDIS_EXPIRE = (ENV['REDIS_EXPIRE'] || 3600).to_i.freeze

    def initialize
      @redis_pool ||= ConnectionPool.new(size: TOTAL_SIZE_REDIS_POOL, timeout: CONNECTION_TIMEOUT_REDIS_POOL) do
        Redis.new(url: REDIS_URL)
      end
    end

    def perform(idempotency_key:)
      # idempotency_key does not exist
      raise "header 'x-idempotency-key' is required to be sent." unless idempotency_key
      
      # response key for redis
      response_key = "#{IDEMPOTENCY_KEY_PREFIX}#{idempotency_key}"

      # check if the operation is completed/successfully cached
      cached_response = response_data_in_cache(response_key)
      return cached_response if cached_response.any?
      
      begin
        # lock key for redis
        lock_key = "#{LOCK_KEY_PREFIX}#{idempotency_key}"

        # lock value
        lock_value = generate_lock_value

        # lock process
        @redis_pool.with do |redis_conn|
          redis_conn.set(lock_key, lock_value, nx: true, ex: LOCK_TIMEOUT)
        end

        # call your logic
        result = yield

        # success
        if result.persisted?
          @redis_pool.with do |redis_conn|
            redis_conn.hset(response_key, 'status', 'success')
            redis_conn.hset(response_key, 'data', result.to_json)
            redis_conn.expire(response_key, REDIS_EXPIRE)
          end
          
          return { 'status' => 'success', 'data' => result.to_json }
        end

        # fail
        raise 'Failure occurred while saving data.'
      rescue => e
        # error
        raise "Failed to lock : #{e.message}"
      end
    end

    private
      # generate lock value
      def generate_lock_value
        UUIDTools::UUID.random_create.to_s
      end

      # check response data in cache
      def response_data_in_cache(response_key)
        cached_response = @redis_pool.with do |redis_conn|
          redis_conn.hgetall(response_key)
        end
        
        cached_response
      end
  end
end
