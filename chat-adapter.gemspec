# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'chat-adapter'
  spec.version       = '0.0.1'
  spec.authors       = ['Karl-Aksel Puulmann']
  spec.email         = ['macobo@ut.ee']
  spec.summary       = %q{Library which allows to write chatbots for irc, slack and hipchat.}
  spec.homepage      = 'https://github.com/macobo/chat-adapter'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'cinch'
  spec.add_dependency 'logging'
  spec.add_dependency 'redcarpet'
  spec.add_dependency 'rest-client'
  spec.add_dependency 'sinatra'
  spec.add_dependency 'thin'

  spec.add_development_dependency 'minitest', '< 5.0'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'pry'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'

end
