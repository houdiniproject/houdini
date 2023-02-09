# backported from https://github.com/rails/rails/blob/daa00c8357dc12ce24f89d92e4ceeabebb3af3d1/activerecord/test/cases/adapters/postgresql/quoting_test.rb

require 'rails_helper'

describe 'test for cve-2022-44566 ' do
  let!(:raise_int_wider_than_64bit) {ActiveRecord::Base.raise_int_wider_than_64bit  }

  let!(:conn) { ActiveRecord::Base.connection}

  it  'test_raise_when_int_is_wider_than_64bit' do 
    value = 9223372036854775807 + 1
  
    expect { conn.quote(value)}.to raise_error(ActiveRecord::ConnectionAdapters::PostgreSQL::Quoting::IntegerOutOf64BitRange)

    value = -9223372036854775808 - 1

    expect { conn.quote(value) }.to raise_error(ActiveRecord::ConnectionAdapters::PostgreSQL::Quoting::IntegerOutOf64BitRange)

  end

  it 'test_do_not_raise_when_int_is_not_wider_than_64bit' do
    value = 9223372036854775807
    assert_equal "9223372036854775807", conn.quote(value)

    value = -9223372036854775808
    assert_equal "-9223372036854775808", conn.quote(value)
  end

  it 'test_do_not_raise_when_raise_int_wider_than_64bit_is_false' do
    ActiveRecord::Base.raise_int_wider_than_64bit = false
    value = 9223372036854775807 + 1
    assert_equal "9223372036854775808", conn.quote(value)
    ActiveRecord::Base.raise_int_wider_than_64bit = raise_int_wider_than_64bit
  end

end
