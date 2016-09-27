require 'rake'

Gem::Specification.new do |s|
  s.name       = 'jerakia-datasource-vault'
  s.version    = '0.1.0'
  s.date       = %x{ /bin/date '+%Y-%m-%d' }
  s.summary    = 'Jerakia data source plugin for vault'
  s.description = 'Jerakia datasource plugin for vault'
  s.authors     = [ 'Craig Dunn' ]
  s.email       = 'craig@craigdunn.org'
  s.files       = [ Rake::FileList["lib/**/*"].to_a ].flatten
  s.homepage    = 'http://github.com/crayfishx/jerakia-vault'
  s.license     = 'Apache 2.0'
  s.add_runtime_dependency 'jerakia', '~> 1.1', '>= 1.1.0'
  s.add_runtime_dependency 'vault', '~> 0.6', '>= 0.6.0'
end
