module Kiqit
  module Workers
    module ActiveRecord
      class LoneWorker < Kiqit::Workers::Base
        def perform(klass, id, method, *args)
          # Remove the loner flag from redis
          digest       = Kiqit::PayloadHelper.get_digest(klass, method, args)
          Sidekiq.redis.del(digest)
          
          args         = Kiqit::ArgsParser.args_from_sidekiq(args)
          runner_klass = klass.constantize
          record       = runner_klass.find(id)

          perform_job(record, method, args)
        end
      end
    end
  end
end