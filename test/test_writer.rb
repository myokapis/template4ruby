require 'test/unit'
require 'template4ruby'
require 'template4ruby/writer'

module Template4Ruby

# Author::    Gene Graves  (gem.developers@myokapis.net)
# Copyright:: Copyright (c) 2015, Gene Graves
# License::   Redistributes under the BSD 2-Clause license. See the gem LICENSE file for terms.

class TestWriter < Test::Unit::TestCase

  # test a simple template
  def test_level_one()
    writer = Template4Ruby::Writer.new({template: template.join("\n")})

    output = writer.get_content

    expected = assemble_output(0, -1).join("\n\n")
    assert_equal expected, output
  end

  # test nested sections
  def test_level_two()
    writer = Template4Ruby::Writer.new({template: template.join("\n")})

    writer.select_section(:SECTION1)
    writer.append_section
    writer.deselect_section
    output = writer.get_content

    expected = assemble_output(0..3, 12..13, 16..18).join("\n")
    assert_equal expected, output
  end

  # test three levels of nested sections
  def test_level_three()
    writer = Template4Ruby::Writer.new({template: template.join("\n")})
    
    writer.select_section(:SECTION1)
    writer.select_section(:SECTION2)
    writer.set_section({'field1' => 'field1', :field4 => 'field4'})
    writer.append_section
    writer.deselect_section
    writer.select_section(:SECTION3)
    writer.set_field(:field2, 'field2')
    writer.append_section
    writer.deselect_section
    writer.append_section
    writer.deselect_section
    output = writer.get_content

    expected = field_replace(assemble_output(0..5, 10..18), fields)

    assert_equal expected.join("\n"), output 
  end

  # test four levels of nested sections
  def test_level_four()
    writer = Template4Ruby::Writer.new({template: template.join("\n")})
    
    writer.select_section(:SECTION1)
    writer.select_section(:SECTION2)
    writer.select_section(:SECTION4)
    writer.set_section_multiple(data)
    writer.deselect_section
    writer.set_section({'field1' => 'field1', :field4 => 'field4'})
    writer.append_section
    writer.deselect_section
    writer.select_section(:SECTION3)
    writer.set_field(:field2, 'field2')
    writer.set_field(:field3, 'this is a nonexistent field and should be ignored')
    writer.append_section
    writer.deselect_section
    writer.append_section
    writer.deselect_section
    output = writer.get_content

    expected = field_replace(assemble_output(0..5), fields)
    data.each do |item|
      expected += field_replace(assemble_output(6..9), item)
    end
    expected += field_replace(assemble_output(10..18), fields)

    assert_equal expected.join("\n"), output
  end

  # verify the current_section_name is correct after each select_section
  # and deselect_section call.
  def test_current_section_name
    actual = []

    writer = Template4Ruby::Writer.new({template: template.join("\n")})
    
    actual << writer.current_section_name
    writer.select_section(:SECTION1)
    actual << writer.current_section_name
    writer.select_section(:SECTION2)
    actual << writer.current_section_name
    writer.select_section(:SECTION4)
    actual << writer.current_section_name
    writer.deselect_section
    actual << writer.current_section_name
    writer.deselect_section
    actual << writer.current_section_name
    writer.select_section(:SECTION3)
    actual << writer.current_section_name
    writer.deselect_section
    actual << writer.current_section_name
    writer.deselect_section
    actual << writer.current_section_name

    expected = [:template, :SECTION1, :SECTION2, :SECTION4, :SECTION2,
                :SECTION1, :SECTION3, :SECTION1, :template]

    assert_equal expected, actual
  end

  # test error conditions


  # verify that an error is raised when an improperly formatted 
  # template is loaded.
  def test_append_no_section
    writer = Template4Ruby::Writer.new({template: template.join("\n")})

    assert_raise(RuntimeError) do
      writer.append_section
    end
  end

  # verify that an error is raised when a template containing sections
  # with duplicate names are loaded.
  def test_bad_template
    # create a template with a duplicate section name
    bad_template = template[13..15] << template[13..15]

    assert_raise(RuntimeError) do
      writer = Template4Ruby::Writer.new({template: bad_template.join("\n")})
    end
  end

  # verify that an error is raised when there is no section selected at
  # the time that deselect_section is called.
  def test_deselect_no_section
    writer = Template4Ruby::Writer.new({template: template.join("\n")})

    assert_raise(RuntimeError) do
      writer.deselect_section
    end
  end

  # verify that an error is raised when a section is requested that
  # does not exist in the current section.
  def test_select_invalid_section
    writer = Template4Ruby::Writer.new({template: template.join("\n")})

    assert_raise(RuntimeError) do
      writer.select_section(:SECTION44)
    end
  end

  # helper methods

  # helper method to build expected results
  def assemble_output(*params)
    output = []

    params.each do |index|
      selection = [template[index]].flatten

      selection.each do |item|
        output.push(item =~ /^\s*<!-- @@[A-Z0-9_]+@@ -->\s*\r*\n*$/ ? '' : item)
      end
    end

    return output
  end

  # data for testing multiple replacements
  def data
  [
    {field3: 'field3a'},
    {field3: 'field3b'},
    {field3: 'field3c'}
  ]
  end

  # data for replacing field placeholders
  def fields
  {
    'field1' => 'field1',
    'field4' => 'field4',
    'field2' => 'field2'
  }
  end

  # helper method to replace field place holders
  def field_replace(input, hash)
    arr = [input].flatten

    hash.each do |key, val|
      arr.collect! {|item| item.gsub("@@#{key}@@", val)}
    end

    return arr
  end

  # array of data for constructing a template
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
