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
      string_column_names = column_names.map(&:to_s)

      # Ensure the primary key is selected so we can use it as an offset
      # `pluck` already handles duplicate column names, and it keeps the first occurence
      id_in_columns_requested = string_column_names.include?(primary_key)
      column_names.unshift(primary_key) unless string_column_names.include?(primary_key)
      id_position_in_response = column_names.index(primary_key)

      relation = self
      batch_size = options[:batch_size] || 1000

      relation = relation.reorder(batch_order).limit(batch_size)
      batch_relation = relation

      loop do
        batch = batch_relation.pluck(*column_names)
        ids = batch.map { |record| record.at(id_position_in_response) }

        break if ids.empty?

        primary_key_offset = ids.last

        unless id_in_columns_requested
          batch.collect! do |record|
            record.delete_at(id_position_in_response)
            record
          end
        end

        batch.flatten! if string_column_names.size == 1

        yield batch

        break if ids.length < batch_size
        batch_relation = relation.where(arel_attribute(primary_key).gt(primary_key_offset))
      end
    end
  end
end
