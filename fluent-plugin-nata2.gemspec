# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'fluent-plugin-nata2'
  spec.version       = '0.0.3'
  spec.authors       = ['studio3104']
  spec.email         = ['studio3104.com@gmail.com']
  spec.summary       = %q{fluent-plugin to post slow query logs to Nata2 server}
  spec.description   = %q{fluent-plugin to post slow query logs to Nata2 server}
  spec.homepage      = 'https://github.com/studio3104/fluent-plugin-nata2'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'fluentd', ['>= 0.14.0', '< 2']
  spec.add_runtime_dependency 'fluent-mixin-rewrite-tag-name'
  spec.add_runtime_dependency 'mysql-slowquery-parser'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'test-unit'
end
