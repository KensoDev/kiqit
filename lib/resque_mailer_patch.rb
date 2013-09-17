module Sidekiq
  module Mailer
    module ClassMethods
      def perform(action, *args)
        args = PerformLater::ArgsParser.args_from_sidekiq(args)
        self.send(:new, action, *args).message.deliver
      end
    end

    class MessageDecoy
      def deliver
        args = PerformLater::ArgsParser.args_to_sidekiq(@args)
        sidekiq.enqueue(@mailer_class, @method_name, *args)
      end
    end
  end
end