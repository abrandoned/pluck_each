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

    def pluck_in_batches(*args)
      options = args.extract_options!
      relation = self
      batch_size = options[:batch_size] || 1000
      primary_key_offset = 0

      relation = relation.reorder(pluck_batch_order).offset(primary_key_offset).limit(batch_size)
      records = relation.pluck(*args)

      while records.any?
        records_size = records.size
        primary_key_offset += records_size
        break if records_size <= 0

        yield records

        break if records_size < batch_size
        records = relation.where(table[primary_key].gt(primary_key_offset)).pluck(*args)
      end
    end

    private

    def pluck_batch_order
      "#{quoted_table_name}.#{quoted_primary_key} ASC"
    end

  end
end
