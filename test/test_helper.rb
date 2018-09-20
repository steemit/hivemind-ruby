$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'

SimpleCov.start
SimpleCov.merge_timeout 3600

require 'hive'
require 'minitest/autorun'

require 'minitest/hell'
require 'minitest/proveit'

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

class Minitest::Test
  # See: https://gist.github.com/chrisroos/b5da6c6a37ac8af5fe78
  parallelize_me! unless defined? WebMock
end

class Hive::Test < MiniTest::Test
  defined? prove_it! and prove_it!
end
