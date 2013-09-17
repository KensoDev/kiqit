module Kiqit
  module Workers
    module Objects
      class LoneWorker < Kiqit::Workers::Base
        def perform(klass_name, method, *args)
          digest = Kiqit::PayloadHelper.get_digest(klass_name, method, args)
          Sidekiq.redis.del(digest)

          arguments = Kiqit::ArgsParser.args_from_sidekiq(args)
          
          perform_job(klass_name.constantize, method, arguments)
        end
      end
    end
  end
end
