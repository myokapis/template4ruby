#!/usr/bin/env ruby
require 'mkmf'
require 'rbconfig'

this_dir = File.expand_path(File.dirname(__FILE__))
tpllib_dir = File.expand_path(File.join(this_dir, 'tpllib'))

LIBDIR = RbConfig::CONFIG['libdir']
INCLUDEDIR = RbConfig::CONFIG['includedir']

# setup search paths
if RbConfig::CONFIG['target_os'] =~ /mswin/
  HEADER_DIRS = [INCLUDEDIR, this_dir, tpllib_dir]
  LIB_DIRS = [LIBDIR, this_dir, tpllib_dir]
else
  HEADER_DIRS =
  [
    '/opt/local/include',
    '/usr/local/include',
    INCLUDEDIR,
    '/usr/include',
    tpllib_dir,
    this_dir
  ]

  LIB_DIRS =
  [
    '/opt/local/lib',
    'usr/local/lib',
    LIBDIR,
    'usr/lib',
    tpllib_dir,
    this_dir
  ]
end

dir_config('tpl4rb', HEADER_DIRS, LIB_DIRS)

# define a helper method to handle missing headers/libraries
def abort_config(file_name, file_type='header')
  abort "The #{file_type}, #{file_name}, was not found."
end

# ensure headers are found
['ruby.h', 'tpllib.h'].each do |header|
  abort_config(header) unless find_header(header)
end

# create the make file
create_header
create_makefile 'tpl4rb/tpl4rb'
