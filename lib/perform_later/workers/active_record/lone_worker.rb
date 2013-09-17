module PerformLater
  module Workers
    module ActiveRecord
      class LoneWorker < PerformLater::Workers::Base
        def perform(klass, id, method, *args)
          # Remove the loner flag from redis
          digest       = PerformLater::PayloadHelper.get_digest(klass, method, args)
          Sidekiq.redis.del(digest)
          
          args         = PerformLater::ArgsParser.args_from_sidekiq(args)
          runner_klass = klass.constantize
          record       = runner_klass.find(id)

          perform_job(record, method, args)
        end
      end
    end
  end
end