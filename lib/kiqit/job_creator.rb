module Kiqit
  class JobCreator
    
    attr_reader :queue, :worker, :klass_name, :id, :method
    attr_accessor :args

    def initialize(queue, worker, klass_name, id, method, *args)
      @queue       = queue
      @worker      = worker
      @klass_name  = klass_name
      @id          = id
      @method      = method
      @args        = args
    end

    def enqueue(delay=nil)
      params = {}
      if delay
        delay = delay.is_a?(Hash) ? delay[:delay] : delay
        params["at"] = (Time.now + delay).to_i
      end

      params.merge!({"queue" => queue, "class" => worker, "args" => [klass_name, id, method, *args]})

      Sidekiq::Client.push(params)
    end
  end
end
