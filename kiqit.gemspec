# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "kiqit/version"

Gem::Specification.new do |s|
  s.name        = "kiqit"
  s.version     = Kiqit::VERSION
  s.authors     = ["Avi Tzurel", "Tom Caspy"]
  s.email       = ["avi@kensodev.com", "tom@kensodev.com"]
  s.homepage    = "http://www.github.com/kensodev/kiqit"
  s.summary     = %q{Queue any method in any class or instance with no need for additional Worker class and no extra code}
  s.description = %q{Queue any method in any class or instance with no need for additional Worker class and no extra code}

  s.rubyforge_project = "kiqit"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'sidekiq', '~> 2.17'
  s.add_dependency 'activerecord'


  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'fakeredis'
end
