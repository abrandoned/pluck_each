require "pluck_each/version"
require "active_record"
require "active_support/core_ext/array/extract_options"

module PluckEach
end

module ActiveRecord
  module Batches

    IS_RAILS_6_1_PLUS = ::Gem::Version.new(::ActiveRecord.version) >= ::Gem::Version.new("6.1.0")

    def pluck_each(*args)
      pluck_in_batches(*args) do |values|
        values.each { |value| yield value }
      end
    end

    def pluck_in_batches(*column_names)
      options = column_names.extract_options!
      string_column_names = column_names.map(&:to_s)

      # Ensure the primary key is selected so we can use it as an offset
      id_in_columns_requested = string_column_names.include?(primary_key)
      id_only_field_requested = id_in_columns_requested && string_column_names.size == 1
      string_column_names.unshift(primary_key) unless id_in_columns_requested
      id_position_in_response = string_column_names.index(primary_key)

      relation = self
      batch_size = options[:batch_size] || 1000

      if IS_RAILS_6_1_PLUS
        relation = relation.reorder(batch_order(:asc)).limit(batch_size)
      else
        relation = relation.reorder(batch_order).limit(batch_size)
      end

      batch_relation = relation

      loop do
        batch = batch_relation.pluck(*string_column_names)
        break if batch.empty?

        primary_key_offset = batch.last

        if !id_only_field_requested
          primary_key_offset = primary_key_offset.at(id_position_in_response)

          unless id_in_columns_requested
            batch.collect! do |record|
              record.delete_at(id_position_in_response)
              record
            end
          end
        end

        batch.flatten! if column_names.size == 1

        yield batch

        break if batch.size < batch_size

        # Rails 5 introduced "arel_attribute" but keeps support for "table" so using
        # "table" as the basis for this for now
        batch_relation = relation.where(table[primary_key].gt(primary_key_offset))
      end
    end
  end
end
