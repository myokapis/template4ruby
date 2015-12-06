require 'tpl4rb/tpl4rb'

module Template4Ruby

# Author::    Gene Graves  (gem.developers@myokapis.net)
# Copyright:: Copyright (c) 2015, Gene Graves
# License::   Redistributes under the BSD 2-Clause license. See the gem LICENSE file for terms.

class Writer < Template4Ruby::Base

  # Initializes a template writer. The template is created from a string
  # if params contains the :template key. If params contains a :file_path
  # key, then the template is loaded from the given file path.
  def initialize(params)
    @stack = []
    @template = get_template(params)
    result = load_string(@template)

    raise get_message(result) if result != TPL_OK
  end

  # Appends the current section to the contents.
  # Returns true.
  # append_section() --> true
  def append_section()
    result = super()
    return true if result == TPL_OK
    raise get_message(result)
  end

  # Returns the name of the currently selected section or :template if
  # no section has been selected.
  # current_section_name --> symbol
  def current_section_name()
    section_name = @stack[-1]
    return section_name.nil? ? :template : section_name
  end

  # Deselects the current section and selects the containing section.
  # Raises an error if there is no section outside of the current 
  # section.
  # Returns true.
  # deselect_section() --> true
  def deselect_section()
    result = super()
    raise get_message(result) if result != TPL_OK
    @stack.pop
    return true
  end

  # Returns all data that has been appended to the output
  # get_content() --> string
  def get_content()
    return super()
  end

  # Removes all appended output and returns the template to its
  # pristine state.
  # Returns true.
  # reset() --> true
  def reset()
    super()
    return true
  end

  # Selects the section corresponding to the given section name.
  # Raises an error if the requested section is not found in the
  # current section.
  # Returns true.
  # select_section(section_name) --> true
  def select_section(section_name)
    result = super(section_name.to_s)
    raise get_message(result) if result != TPL_OK
    @stack.push(section_name.to_sym)
    return true
  end

  # Replaces all field placeholders in the current section that match
  # a key in the given section_data hash. Each field placeholder is
  # replaced with the section_data value corresponding to its key.
  # Returns true.
  # set_section(keyed_obj) --> true
  def set_section(keyed_obj)
    keyed_obj.each do |key, val|
      set_field(key.to_s, val.to_s)
    end
    return true
  end

  # Replaces all field placeholders in the current section that match
  # a key in the given section_data hash. Each field placeholder is
  # replaced with the section_data value corresponding to its key.
  # The section is then appended to the output. The replace and append
  # actions are performed once for each set of data given.
  # Returns true.
  # set_section_multiple(enumerable_obj) --> true
  def set_section_multiple(enumerable_obj)
    enumerable_obj.each do |keyed_obj|
      set_section(keyed_obj)
      append_section
    end
    return true
  end

  # Replaces the given field placeholder in the current section
  # with the given value.
  # Returns true.
  # set_field(field_name, field_value) --> true
  def set_field(field_name, field_value)
    super field_name.to_s, field_value.to_s
  end

  # Returns the template text that is loaded in this writer.
  # template() --> string
  def template
    return @template
  end

  protected

  # Maps the tpllib error codes to readable error messages.
  def error_messages
  {
    TPL_SECTION_NOT_FOUND_ERROR => 'The requested section was not found.',
    TPL_NO_SECTION_SELECTED_ERROR => 'No section has been selected.',
    TPL_SYNTAX_ERROR => 'A syntax error was detected.',
    TPL_NOT_FOUND_ERROR => 'The requested object was not found.',
    TPL_READ_ERROR => 'An error occurred while reading.',
    TPL_WRITE_ERROR => 'An error occurred while writing.',
    TPL_OPEN_ERROR => 'An error occurred while opening the stream.'
  }
  end

  # Looks up the error message associated with a tpllib error code.
  # Returns a generic message if the error is not identified.
  def get_message(key)
    msg = error_messages[key]
    return msg.nil? ? 'An unspecified error occurred.' : msg
  end

  # Reads the template text from a file if a file path is specified in
  # the params. Otherwise, returns the template supplied in the params.
  # Raises an error if neither a template nor a file path were provided.
  def get_template(params)
    if params[:file_path]
      return get_template_from_file(params[:file_path])
    elsif params[:template]
      return params[:template]
    else
      raise 'A valid template file path or template text is required.'
    end
  end

  # Calls the base method to read a template from the file system.
  # Returns the template text if the template is read successfully.
  # Otherwise raises an error.
  def get_template_from_file(file_path)
    template_text = nil

    File.open(file_path, 'r') do |f_in|
      template_text = f_in.read
    end

    return template_text
  end

end

end
