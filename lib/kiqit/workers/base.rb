module Kiqit
  module Workers
		class Base

      include Sidekiq::Worker
      
  		protected
  			def perform_job(object, method, arguments)
  				unless arguments.empty?
            if arguments.size == 1
              object.send(method, arguments.first)
            else
              object.send(method, *arguments)
            end
          else
            object.send(method)
          end
  			end
  		end
	end
end