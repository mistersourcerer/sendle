# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require "sendle/version"

Gem::Specification.new do |s|
  s.name        = "sendle"
  s.version     = Sendle::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ricardo Valeriano"]
  s.email       = ["ricardo@backslashes.net"]
  s.homepage    = "https://github.com/ricardovaleriano/sendle"
  s.summary     = %q{A file system watcher to send new files to your kindle}
  s.description = %q{A file system watcher to send new files to your kindle}

  s.rubyforge_project = "sendle"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.executables   = ['sendle']

  s.add_runtime_dependency 'gmail', '>= 0.3.4'
  s.add_runtime_dependency 'rb-fsevent', '>= 0'
end

