module PerformLater
  module Workers
    module Objects
      class LoneWorker < PerformLater::Workers::Base
        def perform(klass_name, method, *args)
          digest = PerformLater::PayloadHelper.get_digest(klass_name, method, args)
          Sidekiq.redis.del(digest)

          arguments = PerformLater::ArgsParser.args_from_sidekiq(args)
          
          perform_job(klass_name.constantize, method, arguments)
        end
      end
    end
  end
end
