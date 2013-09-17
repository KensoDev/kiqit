require "net/http"
require "uri"
require "kiqit"
require "rspec"
require "support/database_connection"
require "support/database_models"
require "redis"
require 'fakeredis/rspec'

RSpec.configure do |config|
  config.mock_with :rspec

  config.before(:all) do
    dir = File.join(File.dirname(__FILE__), 'support/db')
    
    old_db = File.join(dir, 'test.sqlite3')
    FileUtils.rm(old_db) if File.exists?(old_db)
    FileUtils.cp(File.join(dir, '.blank.sqlite3'), File.join(dir, 'test.sqlite3'))
  end

  config.before(:suite) do
    $redis = {}
    $real_redis = Redis.new
    Sidekiq.redis = $redis
  end

  config.before(:each) do
    Sidekiq.redis{|i| i.flushdb}
  end

  config.after(:each) do
    Kiqit::Plugins.clear_finder!
    $real_redis.flushdb
  end
end
