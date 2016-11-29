require "pluck_each/version"
require "active_record"
require "active_support/core_ext/array/extract_options"

module PluckEach
end

module ActiveRecord
  module Batches

    def pluck_each(*args)
      pluck_in_batches(*args) do |values|
        values.each { |value| yield value }
      end
    end

    def pluck_in_batches(*column_names)
      options = column_names.extract_options!
      batch_size = options[:batch_size] || 1000

      in_batches(:of => batch_size, :load => false) do |batch|
        yield batch.pluck(*column_names)
      end
    end
  end
end
