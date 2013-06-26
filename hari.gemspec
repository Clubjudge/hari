# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'hari/version'

Gem::Specification.new do |s|
  s.name          = 'hari'
  s.version       = Hari::VERSION
  s.summary       = 'Hari is a graph library on top of Redis + Lua scripts'
  s.description   = <<-MD
    Hari is a graph library on top of Redis database + Lua scripts
  MD

  s.author        = 'Victor Rodrigues'
  s.email         = 'victorc.rodrigues@gmail.com'
  s.homepage      = 'http://github.com/rodrigues/hari'

  s.license       = 'MIT'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.add_dependency 'redis',           '~> 3.0'
  s.add_dependency 'redis-namespace', '~> 1.2'
  s.add_dependency 'hiredis',         '~> 0.4'
  s.add_dependency 'activemodel',     '~> 3.2'
  s.add_dependency 'activesupport',   '~> 3.2'
  s.add_dependency 'yajl-ruby',       '~> 1.1'

  s.add_development_dependency 'bundler', '~> 1.3'
  s.add_development_dependency 'rspec',   '~> 2.13'
  s.add_development_dependency 'rake',    '~> 10.0'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'delorean'
end
