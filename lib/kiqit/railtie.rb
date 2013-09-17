module Kiqit
  class Railtie < ::Rails::Railtie
    config.perf_later = Kiqit::Config
  end
end