require 'singleton'
require 'thread'

module Template4Ruby

# Author::    Gene Graves  (gem.developers@myokapis.net)
# Copyright:: Copyright (c) 2015, Gene Graves
# License::   Redistributes under the BSD 2-Clause license. See the gem LICENSE file for terms.

# Maintains templates in a thread-safe cache. The cache is a Singleton
# which allows it to be shared globally within the application.
# * Templates may be added through the []= and add methods
# * Templates may be removed using the remove or clear methods
# * Templates may be retrieved from cache using the [] method

class Cache
  include Singleton

  # Creates a singleton cache object
  def initialize # :notnew:
    @cache = {}
    @cache.default = nil
    @semaphore = Mutex.new
  end

  # Returns a template for the given key or nil if the key is
  # not found in the cache.
  # [](key) --> value or nil
  def [](key)
    @semaphore.synchronize do
      return (@cache[key] || {})[:template]
    end
  end

  # Adds a new template to the cache or replaces an existing template.
  # Returns a value indicating if the template was replaced.
  # []=(key, value) --> true or false
  def []=(key, value)
    add(key, value, true)
  end

  # Adds a new template to the cache or replaces an existing template.
  # Throws an exception if the replace parameter is false and the
  # template already exists in the cache.
  # Returns true if the template was replaced.
  # add(key, value, replace) --> true or false
  def add(key, value, replace=false)
    exists = @cache.has_key?(key)

    @semaphore.synchronize do
      if exists && !replace
        raise "The key, #{key}, is already cached. Use add(key, value, true) to replace the cached data."
      else
        @cache[key] = {template: value, timestamp: Time.now}
      end
    end

    return exists
  end

  # Clears the cache and returns the number of records that were removed.
  # If a retention time is passed as a parameter then only templates
  # that were cached prior to the retention time are removed.
  # Otherwise all templates are removed.
  # Returns the number of cached templates that were removed.
  # clear(retention_time) --> fixnum
  def clear(retention_time=nil)
    initial_item_count = @cache.length

    @semaphore.synchronize do
      if retention_time
        @cache.delete_if do |key, val|
          timestamp = (val || {})[:timestamp]
          timestamp.nil? || timestamp < retention_time
        end
      else
        @cache.clear
      end
    end

    return @cache.length - initial_item_count
  end

  # Returns true if the given key is present in the cache.
  # has_key?(key) --> true or false
  def has_key?(key)
    @semaphore.synchronize do
      return @cache.has_key?(key)
    end
  end

  # Removes a template from the cache for the given key.
  # Returns true if the key was present in the cache.
  # remove(key) --> true or false
  def remove(key)
    @semaphore.synchronize do
      return !!@cache.delete(key)
    end
  end

end

end
