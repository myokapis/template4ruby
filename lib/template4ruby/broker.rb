require 'tpl4rb/tpl4rb'
require_relative 'cache'
require_relative 'writer'

module Template4Ruby

# Author::    Gene Graves  (gem.developers@myokapis.net)
# Copyright:: Copyright (c) 2015, Gene Graves
# License::   Redistributes under the BSD 2-Clause license. See the gem LICENSE file for terms.

# Returns the requested template.
# The requested template is loaded from the cache if it exists.
# Otherwise the template is loaded from disk.
class Broker

  # Caches a template.
  # Returns a value indicating if the template was replaced.
  # cache_template(key, template) --> true or false
  def self.cache_template(key, template)
    cache = Template4Ruby::Cache.instance
    return cache.add(key, template, true)
  end

  # Returns a writer based on a cached template for a given key.
  # If the template is not found in the cache and the is_path parameter
  # is true, the template is loaded from the file system using the
  # given key as the file path.
  # Returns the writer or raises an exception if the template cannot
  # be loaded.
  # Broker::request_writer(key, is_path) --> Template4Ruby::Writer
  def self.request_writer(key, is_path=true)
    cache = Template4Ruby::Cache.instance
    template = cache[key]
    load_file = (is_path && template.nil?)

    params =
    {
      file_path: (load_file ? key : nil),
      template: (load_file ? nil : template)
    }

    writer = Template4Ruby::Writer.new(params)
    cache.add(key, writer.template) if template.nil?

    return writer
  end

end

end
