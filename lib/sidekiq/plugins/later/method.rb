module Sidekiq::Plugins::Later::Method
  extend ActiveSupport::Concern

  module ClassMethods
    def later(method_name, opts={})
      alias_method "now_#{method_name}", method_name
      return unless Kiqit.config.enabled?

      define_method "#{method_name}" do |*args|
        loner          = opts.fetch(:loner, false)
        queue          = opts.fetch(:queue, :generic)
        delay          = opts.fetch(:delay, false)
        klass          = Kiqit::Workers::ActiveRecord::Worker
        klass          = Kiqit::Workers::ActiveRecord::LoneWorker if loner
        args           = Kiqit::ArgsParser.args_to_sidekiq(args)
        digest         = Kiqit::PayloadHelper.get_digest(klass, method_name, args)

        if loner
          return "AR EXISTS!" if Sidekiq.redis{|i| i.get(digest).present?}
          Sidekiq.redis{|i| i.set(digest, 'EXISTS')}
        end

        job = Kiqit::JobCreator.new(queue, klass, send(:class).name, send(:id), "now_#{method_name}", *args)
        job.enqueue(delay)
      end
    end

  end

  def kiqit(queue, method, *args)
    return perform_now(method, args) if plugin_disabled?

    worker  = Kiqit::Workers::ActiveRecord::Worker
    job     = Kiqit::JobCreator.new(queue, worker, self.class.name, self.id, method, *args) 
    enqueue_in_sidekiq_or_send(job)
  end

  def kiqit!(queue, method, *args)
    return perform_now(method, args) if plugin_disabled?
    return "AR EXISTS!" if loner_exists(method, args)
    
    worker  = Kiqit::Workers::ActiveRecord::LoneWorker
    job     = Kiqit::JobCreator.new(queue, worker, self.class.name, self.id, method, *args) 
    enqueue_in_sidekiq_or_send(job)
  end

  def kiqit_in(delay, queue, method, *args)
    return perform_now(method, args) if plugin_disabled?

    worker  = Kiqit::Workers::ActiveRecord::Worker
    job     = Kiqit::JobCreator.new(queue, worker, self.class.name, self.id, method, *args) 
    enqueue_in_sidekiq_or_send(job, delay)
  end
  
  def kiqit_in!(delay, queue, method, *args)
    return  perform_now(method, args) if plugin_disabled?

    worker  = Kiqit::Workers::ActiveRecord::LoneWorker
    job     = Kiqit::JobCreator.new(queue, worker, self.class.name, self.id, method, *args) 
    enqueue_in_sidekiq_or_send(job, delay)
  end



  private 
    def loner_exists(method, args)
      args = Kiqit::ArgsParser.args_to_sidekiq(args)
      digest = Kiqit::PayloadHelper.get_digest(self.class.name, method, args)

      return true unless Sidekiq.redis{ |i| i.get(digest).blank?}
      Sidekiq.redis{|i| i.set(digest, 'EXISTS')}

      return false
    end

    def enqueue_in_sidekiq_or_send(job, delay=nil)
      job.args = Kiqit::ArgsParser.args_to_sidekiq(job.args)
      job.enqueue(delay)
    end
        
    def plugin_disabled?
      !Kiqit.config.enabled?
    end

    def perform_now(method, args)
      return self.send(method, *args)
    end
end
