require 'sidekiq'
require 'active_support/dependencies'
require 'kiqit/version'
require 'kiqit/config'
require 'kiqit/payload_helper'
require 'kiqit/args_parser'
require 'kiqit/plugins'
require 'kiqit/job_creator'
require 'active_record'
require 'object_perform_later'
require 'kiqit/workers/base'
require 'kiqit/workers/active_record/worker'
require 'kiqit/workers/active_record/lone_worker'
require 'kiqit/workers/objects/worker'
require 'kiqit/workers/objects/lone_worker'

module Kiqit
  def self.config
    Kiqit::Config
  end
end

module Sidekiq
  module Plugins
    module Later
      autoload :Method, 'sidekiq/plugins/later/method'
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include Sidekiq::Plugins::Later::Method
end
