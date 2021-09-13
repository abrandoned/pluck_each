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
      _(User.all).must_respond_to :pluck_each
    end

    it 'adds pluck_in_batches to Arel relation nodes' do
      _(User.all).must_respond_to :pluck_in_batches
    end
  end

  describe 'pluck_each' do
    before do
      User.delete_all
      Product.delete_all

      User.create(:first_name => '1', :last_name => '1')
      User.create(:first_name => '2', :last_name => '2')
      User.create(:first_name => '3', :last_name => '3')
      User.create(:first_name => '4', :last_name => '4')
      User.create(:first_name => '5', :last_name => '5')
      Product.create(:name => "1", :value => 1, :user_id => User.first.id)
      Product.create(:name => "2", :value => 2, :user_id => User.first.id)
      Product.create(:name => "3", :value => 3, :user_id => User.first.id)
    end

    it 'plucks :id from scope on association' do
      values = []
      user = User.first
      user.products.pluck_each(:name) do |name|
        values << name
      end

      values.sort!
      _(values).must_equal ["1", "2", "3"]
    end

    it 'plucks :id when only field requested' do
      values = []
      User.all.pluck_each(:id) do |id|
        values << id
      end

      values.sort!
      _(values).must_equal User.all.pluck(:id).sort
    end

    it 'plucks only the fields requested' do
      values = []
      User.all.pluck_each(:first_name) do |first_name|
        values << first_name
      end

      values.sort!
      _(values).must_equal ['1', '2', '3', '4', '5']
    end

    it 'allows batch_size in options to determine batch size' do
      count = 0 
      values = []
      User.all.pluck_each(:first_name, :batch_size => 1) do |first_name|
        values << first_name
        count += 1
      end

      _(count).must_equal(5)
      values.sort!
      _(values).must_equal ['1', '2', '3', '4', '5']
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
      _(batch_sizes).must_equal [1, 2, 2]
    end
  end
end
