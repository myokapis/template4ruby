require 'test/unit'
require 'tempfile'
require 'tmpdir'
require 'template4ruby'
require 'template4ruby/broker'

module Template4Ruby

# Author::    Gene Graves  (gem.developers@myokapis.net)
# Copyright:: Copyright (c) 2015, Gene Graves
# License::   Redistributes under the BSD 2-Clause license. See the gem LICENSE file for terms.

class TestBroker < Test::Unit::TestCase

  # verify creating a writer from a cached template
  def test_request_cached
    cache = Template4Ruby::Cache.instance
    cache.clear
    cache.add(:key1, template.join("\n"))
    
    broker = Template4Ruby::Broker
    writer = broker.request_writer(:key1)

    assert_equal template.join("\n"), writer.template
  end

  # verify creating a writer from a template not in the cache
  def test_request_uncached
    file_path = create_temp_file(template)
    cache = Template4Ruby::Cache.instance
    cache.clear
    
    broker = Template4Ruby::Broker
    writer = broker.request_writer(file_path)

    assert_equal template.join("\n"), writer.template
  end

  # verify an error is raised if a template is requested from an invalid
  # file path
  def test_request_file_not_found
    cache = Template4Ruby::Cache.instance
    cache.clear

    file_path = create_temp_file([''])
    File.delete(file_path) if File.exists?(file_path)
    
    broker = Template4Ruby::Broker

    assert_raise(Errno::ENOENT) do
      writer = broker.request_writer(file_path)
    end
  end

  ## helper methods

  # helper method to create a temp file from an array
  def create_temp_file(text_array)
    file = Tempfile.new('template.html')
    file_path = file.path

    File.open(file_path, 'w') do |f_out|
      f_out.write text_array.join("\n")
    end

    return file_path
  end

  # array of data for creating a template
  def template
  [
    'some text before',
    '<!-- @@SECTION1@@ -->',
    '<div>stuff1</div>',
    '<!-- @@SECTION2@@ -->',
    '<div>@@field1@@</div>',
    '<!-- @@SECTION4@@ -->',
    '<div>stuff4</div>',
    '<div>@@field3@@</div>',
    '<div>stuff5</div>',
    '<!-- @@SECTION4@@ -->',
    '<div>@@field4@@</div>',
    '<!-- @@SECTION2@@ -->',
    '<div>stuff2</div>',
    '<!-- @@SECTION3@@ -->',
    '<div>@@field2@@</div>',
    '<!-- @@SECTION3@@ -->',
    '<div>stuff3</div>',
    '<!-- @@SECTION1@@ -->',
    'some text after'
  ]
  end

end

end
