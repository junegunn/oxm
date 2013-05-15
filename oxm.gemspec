# -*- encoding: utf-8 -*-
require File.expand_path('../lib/oxm/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Junegunn Choi"]
  gem.email         = ["junegunn.c@gmail.com"]
  gem.description   = %q{An Object-XML-Mapper based on Nokogiri SAX parser}
  gem.summary       = %q{An Object-XML-Mapper based on Nokogiri SAX parser}
  gem.homepage      = "https://github.com/junegunn/oxm"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "oxm"
  gem.require_paths = ["lib"]
  gem.version       = OXM::VERSION

  gem.add_runtime_dependency 'builder', '>= 3.0.0'
  gem.add_runtime_dependency 'nokogiri', '>= 1.5.0'
end
