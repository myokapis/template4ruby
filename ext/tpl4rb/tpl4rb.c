/*
* tpl4rb
*
* C library of functions that wrap tpllib for access by Ruby.
* 
* Copyright (c) 2015, Gene Graves <gemdevelopers@myokapis.net>
* All rights reserved.
* 
* Redistribution and use in source and binary forms, with or without 
* modification, are permitted provided that the following conditions are 
* met:
* 
* 1. Redistributions of source code must retain the above copyright 
* notice, this list of conditions and the following disclaimer.
* 
* 2. Redistributions in binary form must reproduce the above copyright 
* notice, this list of conditions and the following disclaimer in the 
* documentation and/or other materials provided with the distribution.
* 
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
* "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
* LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
* A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
* HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
* SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
* LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
* DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY 
* THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
* OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
* 
* **********************************************************************
* 
* Copyright and license terms for tpllib are included with the tpllib 
* source code.
* 
*/

#include <tpl4rb.h>
#include <tpllib/tpllib.h>
#include <tpllib/tpllib.c>
#include <ruby.h>
#include <extconf.h>

VALUE mTpl4Ruby;
VALUE cBase;

/* template methods */

/* wraps the tpllib method for freeing a template */
static void deallocate(tpl_t *tpl)
{
  tpl_free(tpl);
}

/* wraps the tpllib method for allocating a template */
static VALUE allocate(VALUE klass)
{
  tpl_t* tpl = tpl_alloc();

  return Data_Wrap_Struct(klass, NULL, deallocate, tpl);
}

/* creates a Ruby initialize method */
static VALUE initialize(VALUE self)
{
  return self;
}

/* wraps the tpllib method for loading a template from a file */
static VALUE load_file(VALUE self, VALUE filename)
{
  tpl_t* tpl;
  Data_Get_Struct(self, tpl_t, tpl);
  int result = tpl_load(tpl, StringValuePtr(filename));
  return(INT2FIX(result));
}

/* wraps the tpllib method for loading a template from a string */
static VALUE load_string(VALUE self, VALUE tpl_str)
{
  tpl_t* tpl;
  char* data = StringValuePtr(tpl_str);
  int len = strlen(data);
  Data_Get_Struct(self, tpl_t, tpl);
  int result = tpl_from_string(tpl, data, len);
  return(INT2FIX(result));
}

/* wraps the tpllib method for reseting a template */
static void reset(VALUE self)
{
  tpl_t* tpl;
  Data_Get_Struct(self, tpl_t, tpl);
  tpl_reset(tpl);
}

/* wraps the tpllib method for replacing a field with a value */
static void set_field(VALUE self, VALUE field_name, VALUE field_value)
{
  tpl_t* tpl;
  const char* field;
  const char* val;
  int len;

  field = StringValuePtr(field_name);
  val = StringValuePtr(field_value);
  len = strlen(val);
  Data_Get_Struct(self, tpl_t, tpl);
  tpl_set_field(tpl, field, val, len);
}

/* wraps the tpllib method for selecting a named section */
static int select_section(VALUE self, VALUE section_name)
{
  tpl_t* tpl;
  char* section = StringValuePtr(section_name);
  Data_Get_Struct(self, tpl_t, tpl);
  int result = tpl_select_section(tpl, section);
  return(INT2FIX(result));
}

/* wraps the tpllib method for deselecting the current section */
static VALUE deselect_section(VALUE self)
{
  tpl_t* tpl;
  Data_Get_Struct(self, tpl_t, tpl);
  int result = tpl_deselect_section(tpl);
  return(INT2FIX(result));
}

/* wraps the tpllib method for appending a template section to the output */
static VALUE append_section(VALUE self)
{
  tpl_t* tpl;
  Data_Get_Struct(self, tpl_t, tpl);
  int result = tpl_append_section(tpl);
  return(INT2FIX(result));
}

/* wraps the tpllib method for getting the content appended to the output */
static VALUE get_content(VALUE self)
{
  tpl_t* tpl;
  char* buffer;
  int length;

  Data_Get_Struct(self, tpl_t, tpl);
  length = tpl_length(tpl);
  buffer = malloc(length + 1);
  tpl_get_content(tpl, buffer);
  return (VALUE)rb_str_new(buffer, length);
}

/* code run by `require` */
void Init_tpl4rb()
{
  mTpl4Ruby = rb_define_module("Template4Ruby");
  cBase = rb_define_class_under(mTpl4Ruby, "Base", rb_cObject);
  rb_define_alloc_func(cBase, allocate);

  rb_define_method(cBase, "initialize", RUBY_METHOD_FUNC(initialize), 0);
  rb_define_method(cBase, "load_file", RUBY_METHOD_FUNC(load_file), 1);
  rb_define_method(cBase, "load_string", RUBY_METHOD_FUNC(load_string), 1);
  rb_define_method(cBase, "reset", RUBY_METHOD_FUNC(reset), 0);
  rb_define_method(cBase, "set_field", RUBY_METHOD_FUNC(set_field), 2);
  rb_define_method(cBase, "select_section", RUBY_METHOD_FUNC(select_section), 1);
  rb_define_method(cBase, "deselect_section", RUBY_METHOD_FUNC(deselect_section), 0);
  rb_define_method(cBase, "append_section", RUBY_METHOD_FUNC(append_section), 0);
  rb_define_method(cBase, "get_content", RUBY_METHOD_FUNC(get_content), 0);

  rb_define_const(cBase, "TPL_OK", INT2FIX(TPL_OK));
  rb_define_const(cBase, "TPL_SECTION_NOT_FOUND_ERROR", INT2FIX(TPL_SECTION_NOT_FOUND_ERROR));
  rb_define_const(cBase, "TPL_NO_SECTION_SELECTED_ERROR", INT2FIX(TPL_NO_SECTION_SELECTED_ERROR));
  rb_define_const(cBase, "TPL_SYNTAX_ERROR", INT2FIX(TPL_SYNTAX_ERROR));
  rb_define_const(cBase, "TPL_NOT_FOUND_ERROR", INT2FIX(TPL_NOT_FOUND_ERROR));
  rb_define_const(cBase, "TPL_READ_ERROR", INT2FIX(TPL_READ_ERROR));
  rb_define_const(cBase, "TPL_WRITE_ERROR", INT2FIX(TPL_WRITE_ERROR));
  rb_define_const(cBase, "TPL_OPEN_ERROR", INT2FIX(TPL_OPEN_ERROR));
}
