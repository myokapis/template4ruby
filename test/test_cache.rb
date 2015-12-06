require 'test/unit'
require 'template4ruby'
require 'template4ruby/cache'

module Template4Ruby

# Author::    Gene Graves  (gem.developers@myokapis.net)
# Copyright:: Copyright (c) 2015, Gene Graves
# License::   Redistributes under the BSD 2-Clause license. See the gem LICENSE file for terms.

class TestCache < Test::Unit::TestCase

  # verify adding templates to the cache
  def test_add
    c = Template4Ruby::Cache.instance
    c.clear
    expected = {}

    1.upto(10) do |num|
      key = "key#{num}".to_sym
      val = "value#{num}"
      c.add(key, val)
      expected[key] = val
    end

    sleep(0.1)
    t = Time.now

    11.upto(20) do |num|
      key = "key#{num}".to_sym
      val = "value#{num}"
      c[key] = val
      expected[key] = val
    end

    actuals = {}

    expected.each do |key, val|
      actuals[key] = c[key]
    end

    expected[:length] = 20
    actuals[:length] = actuals.length
    
    assert_equal expected, actuals
  end

  # verify an error is thrown when adding a duplicate key to the cache
  # when the replace cache flag is false.
  def test_add_with_error
    c = Template4Ruby::Cache.instance
    c.clear
    c.add(:key1, 'value1')
    err_msg = "The key, key1, is already cached. Use add(key, value, true) to replace the cached data."
    
    assert_raise RuntimeError, err_msg do
      c.add(:key1, 'some value')
    end
  end

  # verify clearing the cache
  def test_clear_all
    c = Template4Ruby::Cache.instance
    c.clear
    expected = {}

    1.upto(10) do |num|
      key = "key#{num}".to_sym
      val = "value#{num}"
      c.add(key, val)
      expected[key] = nil
    end

    sleep(0.1)

    11.upto(20) do |num|
      key = "key#{num}".to_sym
      val = "value#{num}"
      c.add(key, val)
      expected[key] = nil
    end

    c.clear
    actuals = {}

    expected.each do |key, val|
      actuals[key] = c[key]
    end

    expected[:length] = 20
    actuals[:length] = actuals.length
    
    assert_equal expected, actuals
  end

  # verify clearing the cache based on a retention parameter
  def test_clear_retention
    c = Template4Ruby::Cache.instance
    c.clear
    expected = {}

    1.upto(10) do |num|
      key = "key#{num}".to_sym
      val = "value#{num}"
      c.add(key, val)
      expected[key] = nil
    end

    sleep(0.1)
    t = Time.now

    11.upto(20) do |num|
      key = "key#{num}".to_sym
      val = "value#{num}"
      c.add(key, val)
      expected[key] = val
    end

    c.clear(t)
    actuals = {}

    expected.each do |key, val|
      actuals[key] = c[key]
    end

    expected[:length] = 20
    actuals[:length] = actuals.length
    
    assert_equal expected, actuals
  end

  # verify removing a key from the cache
  def test_remove
    c = Template4Ruby::Cache.instance
    c.clear
    expected = {}

    1.upto(10) do |num|
      key = "key#{num}".to_sym
      val = "value#{num}"
      c.add(key, val)
      expected[key] = (num == 7 ? nil : val)
    end

    c.remove(:key7)
    actuals = {}

    expected.each do |key, val|
      actuals[key] = c[key]
    end

    expected[:length] = 10
    actuals[:length] = actuals.length
    
    assert_equal expected, actuals
  end

  # verify that the cache is a singleton
  def test_singleton
    err_msg = ""

    assert_raise NoMethodError, err_msg do
      c = Template4Ruby::Cache.new
    end
  end

  # verify the cache is thread safe
  def test_thread_safe
    c1 = nil
    c2 = nil

    c = Template4Ruby::Cache.instance
    c.clear
    c.add(:key2, 'value2')

    thr1 = Thread.new do
      c1 = Template4Ruby::Cache.instance
      c1.add(:key1, 'value1')
    end
    
    thr2 = Thread.new do
      c2 = Template4Ruby::Cache.instance
      c2.add(:key2, 'updated2', true)
      c2.add(:key3, 'value3')
    end

    thr1.join
    thr2.join
    
    sleep(0.1) until !(thr1.status || thr2.status)
    
    expected = ['value1', 'updated2', 'value3']
    actuals = [c[:key1], c[:key2], c[:key3]]

    assert_equal expected, actuals
  end

end

end
