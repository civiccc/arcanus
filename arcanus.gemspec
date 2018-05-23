$LOAD_PATH << File.expand_path('../lib', __FILE__)
require 'arcanus/constants'
require 'arcanus/version'

Gem::Specification.new do |s|
  s.name             = 'arcanus'
  s.version          = Arcanus::VERSION
  s.license          = 'MIT'
  s.summary          = 'Arcanus command line interface'
  s.description      = 'Tool for working with encrypted secrets in repositories'
  s.authors          = ['Brigade Engineering', 'Shane da Silva']
  s.email            = ['eng@brigade.com', 'shane@dasilva.io']
  s.homepage         = Arcanus::REPO_URL

  s.require_paths    = ['lib']

  s.executables      = [Arcanus::EXECUTABLE_NAME]

  s.files            = Dir['lib/**/*.rb']

  s.required_ruby_version = '>= 2.1'

  s.add_dependency 'diffy', '~> 3.1'
  s.add_dependency 'pastel', '~> 0.7'
  s.add_dependency 'tty-prompt', '~> 0.16'
  s.add_dependency 'tty-spinner', '~> 0.8'
  s.add_dependency 'tty-table', '~> 0.10'
end
