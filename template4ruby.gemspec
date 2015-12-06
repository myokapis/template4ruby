Gem::Specification.new do |s|
  s.name = 'template4ruby'
  s.version = '1.0.0.pre'
  s.date = '2015-04-22'
  s.summary = 'Generates documents dynamically from templates'
  s.description = <<-EOF
    Template4Ruby generates dynamic documents from templates. Typically
    templates are HTML or XML documents containing placeholders for
    nested sections and data fields. The gem provides helper methods to 
    facilitate populating placeholders from various data structures and 
    for appending document sections to the output.
  EOF
  s.authors = ['Gene Graves']
  s.email = 'gemdevelopers@myokapis.net'
  s.platform = Gem::Platform::CURRENT
  s.extensions << 'ext/tpl4rb/extconf.rb'
  s.files =
  [
    'History.txt',
    'Manifest.txt',
    'Rakefile',
    'README.md',
    'LICENSE.md',
    'ext/tpl4rb/tpllib/CHANGELOG.txt',
    'ext/tpl4rb/tpllib/LICENSE.txt',
    'ext/tpl4rb/tpllib/README.txt',
    'ext/tpl4rb/tpllib/snprintf.c',
    'ext/tpl4rb/tpllib/tpllib.c',
    'ext/tpl4rb/tpllib/tpllib.h',
    'ext/tpl4rb/tpl4rb.c',
    'ext/tpl4rb/tpl4rb.h',
    'lib/template4ruby.rb',
    'lib/template4ruby/broker.rb',
    'lib/template4ruby/cache.rb',
    'lib/template4ruby/writer.rb',
    'test/test_broker.rb',
    'test/test_cache.rb',
    'test/test_writer.rb'
  ]
  s.homepage = 'https://github.com/myokapis/template4ruby'
  s.license = 'BSD-2'
end
