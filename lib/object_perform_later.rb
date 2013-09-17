module ObjectPerformLater
  def perform_later(queue, method, *args)
    return perform_now(method, args) unless PerformLater.config.enabled?

    worker = PerformLater::Workers::Objects::Worker
    perform_later_enqueue(worker, queue, method, args)
  end

  def perform_later!(queue, method, *args)
    return perform_now(method, args) unless PerformLater.config.enabled?

    return "EXISTS!" if loner_exists(method, args)

    worker = PerformLater::Workers::Objects::LoneWorker
    perform_later_enqueue(worker, queue, method, args)
  end

  private 
    def loner_exists(method, *args)
      digest = PerformLater::PayloadHelper.get_digest(self.name, method, args)

      !Sidekiq.redis{|i| i.setnx(digest, 'EXISTS')}
    end

    def perform_later_enqueue(worker, queue, method, args)
      args = PerformLater::ArgsParser.args_to_sidekiq(args)
      params = {"queue" => queue, "class" => worker, "args" => [self.name, method, *args]}
      Sidekiq::Client.push(params)
    end

    def perform_now(method, args)
      args.size == 1 ? send(method, args.first) : send(method, *args)
    end
end

Object.send(:include, ObjectPerformLater)