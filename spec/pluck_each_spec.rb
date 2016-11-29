require 'spec_helper'
require 'pry'

describe PluckEach do
  File.delete(File.expand_path(File.dirname(__FILE__) + "/test.db")) rescue nil

  ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database => "spec/test.db"
  )
  load_schema

  describe 'API' do
    it 'adds pluck_each to Arel relation nodes' do
      User.all.must_respond_to :pluck_each
    end

    it 'adds pluck_in_batches to Arel relation nodes' do
      User.all.must_respond_to :pluck_in_batches
    end
  end

  describe 'pluck_each' do
    before do
      User.delete_all
      User.create(:first_name => '1', :last_name => '1')
      User.create(:first_name => '2', :last_name => '2')
      User.create(:first_name => '3', :last_name => '3')
      User.create(:first_name => '4', :last_name => '4')
      User.create(:first_name => '5', :last_name => '5')
    end

    it 'plucks :id when only field requested' do
      values = []
      User.all.pluck_each(:id) do |id|
        values << id
      end

      values.sort!
      values.must_equal User.all.pluck(:id).sort
    end

    it 'plucks only the fields requested' do
      values = []
      User.all.pluck_each(:first_name) do |first_name|
        values << first_name
      end

      values.sort!
      values.must_equal ['1', '2', '3', '4', '5']
    end

    it 'allows batch_size in options to determine batch size' do
      count = 0 
      values = []
      User.all.pluck_each(:first_name, :batch_size => 1) do |first_name|
        values << first_name
        count += 1
      end

      count.must_equal(5)
      values.sort!
      values.must_equal ['1', '2', '3', '4', '5']
    end
  end

  describe 'pluck_in_batches' do
    before do
      User.delete_all
      User.create(:first_name => '1', :last_name => '1')
      User.create(:first_name => '2', :last_name => '2')
      User.create(:first_name => '3', :last_name => '3')
      User.create(:first_name => '4', :last_name => '4')
      User.create(:first_name => '5', :last_name => '5')
    end

    it 'allows batch_size in options to determine batch size' do
      batch_sizes = []
      User.all.pluck_in_batches(:first_name, :batch_size => 2) do |first_names|
        batch_sizes << first_names.size
      end

      batch_sizes.sort!
      batch_sizes.must_equal [1, 2, 2]
    end
  end
end
