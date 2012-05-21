require 'perform_later/version'
require 'active_record'
require 'resque_perform_later'
require 'resque_mailer_patch'
require 'object_worker'
require 'object_perform_later'
require 'active_record_worker'
require 'active_record_perform_later'

module PerformLater
  extend self

  def enabled=(value)
    @enabled = value
  end

  def enabled?
    @enabled || false
  end

end