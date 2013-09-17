module Kiqit
  module Workers
    module Objects
      class Worker < Kiqit::Workers::Base
        def perform(klass_name, method, *args)
          arguments = Kiqit::ArgsParser.args_from_sidekiq(args)

          perform_job(klass_name.constantize, method, arguments)
        end
      end
    end
  end
end
