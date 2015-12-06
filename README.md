# Template4Ruby
Template4Ruby provides functionality for generating html and other document formats from templates.

## Templates
Templates consist of three parts - sections, field markers, and text. Text can be plain text, markup, or any other text format that does not conflict with the template structure.

### Sections
Sections separate the template into blocks of text that can be manipulated separately from the rest of the template. Each section has a beginning section marker and an ending section marker. Section markers follow the format of <!-- @@SECTION_NAME@@ -->. All text between a pair of section markers is considered part of the section. Sections may contain other sections, text, and/or field markers.

### Field Markers
Field markers designate the location of fields that may be replaced with data when a template is processed. Field markers follow the format of @@field_name@@.

### Example
An example template containing html markup, nested sections, and field markers follows:

```html
  <html>
  <body>
    <div>
      <!-- @@SECTION1@@ -->
      <div>
        <div>@@namensliste@@</div>
        <ul>
          <!-- @@SECTION2@@ -->
          <li>@@tiere@@</li>
          <!-- @@SECTION2@@ -->
        </ul>
      </div>
      <!-- @@SECTION1@@ -->
    </div>
  </body>
  </html>
```html

## Why Templates?
Template4Ruby was created to separate html markup from the code that generates the web page output. It is ideal for partial pages because there is no need to place partial page content in a separate file. Partial page content can be wrapped in a section within the main page. The template writer can generate a full page or just the section(s) that are needed.

Sections may be appended multiple times with different content which makes generating markup for lists, dropdowns, and tables simple.

Template4Ruby contains functionality for:
* Loading templates from the file system
* Parsing templates into Ruby objects
* Caching parsed templates
* Creating dynamic documents

# Sample Code
A simple example of using all of the components within Template4Ruby follows.

```ruby
require 'template4ruby'

class ExampleTemplate

  def initialize()
    # get the template cache singleton and add a template
    cache = Template4Ruby::Cache.instance
    cache.add(:my_template, template.join("\n"))

    # get a reference to the broker
    @broker = Template4Ruby::Broker
  end

  def write()
    # get an instance of a writer from the broker
    @writer = @broker.request_writer(:my_template)

    # call a method to populate the template with data
    generate_output

    # output the populated template
    puts @writer.get_content.gsub("\n\n", "\n")
  end

  def generate_output
    # select nested sections to get to an inner section
    @writer.select_section(:SECTION1)
    @writer.select_section(:SECTION2)
    @writer.select_section(:SECTION4)

    # append the selected section to the output multiple times with different data
    @writer.set_section_multiple([{field3: 'Item A'},
      {field3: 'Item B'}, {field3: 'Item C'}])

    # release the selected section and return to its parent section
    @writer.deselect_section

    # append the current section to the output
    @writer.append_section

    # release the selected section and return to its parent section
    @writer.deselect_section

    # select a section that is nested in the currently selected section
    @writer.select_section(:SECTION3)

    # populate the selected section with data and append it to the output
    @writer.set_field(:field2, 'field2 data')
    @writer.append_section

    # release the selected section and return to its parent section
    @writer.deselect_section

    # populate the selected section with data and append it to the output
    @writer.set_section({'field1' => 'field1 data', :field4 => 'field4 data'})
    @writer.append_section

    # populate the selected section with different data and append it to the output
    @writer.set_section({'field1' => 'Apples', :field4 => 'Oranges'})
    @writer.append_section

    # release the selected section and return to its parent section
    @writer.deselect_section
  end

  def template
  [
    'some text before',
    '<!-- @@SECTION1@@ -->',
    '<div>some text in section 1</div>',
    '<div>Field1: @@field1@@</div>',
    '<!-- @@SECTION2@@ -->',
    '<div>',
    '  <select>',
    '<!-- @@SECTION4@@ -->',
    '    <option>@@field3@@</option>',
    '<!-- @@SECTION4@@ -->',
    '  </select>',
    '</div>',
    '<!-- @@SECTION2@@ -->',
    '<div>some text in section 3</div>',
    '<!-- @@SECTION3@@ -->',
    '<div>Field2: @@field2@@</div>',
    '<!-- @@SECTION3@@ -->',
    '<div>Field4: @@field4@@</div>',
    '<div>more text in section 1</div>',
    '<!-- @@SECTION1@@ -->',
    'some text after'
  ]
  end

end

et = ExampleTemplate.new()
et.write
```ruby
