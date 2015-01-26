module ObjectKiqit
  def kiqit(queue, method, *args)
    return perform_now(method, args) unless Kiqit.config.enabled?

    worker = Kiqit::Workers::Objects::Worker
    kiqit_enqueue(worker, queue, method, args)
  end

  def kiqit!(queue, method, *args)
    return perform_now(method, args) unless Kiqit.config.enabled?

    return "EXISTS!" if loner_exists(method, args)

    worker = Kiqit::Workers::Objects::LoneWorker
    kiqit_enqueue(worker, queue, method, args)
  end

  private 
    def loner_exists(method, *args)
      digest = Kiqit::PayloadHelper.get_digest(self.name, method, args)

      !Sidekiq.redis{|i| i.setnx(digest, 'EXISTS')}
    end

    def kiqit_enqueue(worker, queue, method, args)
      args = Kiqit::ArgsParser.args_to_sidekiq(args)
      params = {"queue" => queue, "class" => worker, "args" => [self.name, method, *args]}
      Sidekiq::Client.push(params)
    end

    def perform_now(method, args)
      args.size == 1 ? send(method, args.first) : send(method, *args)
    end
end

Object.send(:include, ObjectKiqit)