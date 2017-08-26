class SQLite3Field
  # Represents a single field of a SQLite3 table.
  attr_reader :field_index, :field_name, :data_type, :is_primary_key

  def initialize( field_index, field_name, data_type, is_primary_key = false )
    @data_type = data_type
    @field_index = field_index
    @field_name = field_name
    @is_primary_key = is_primary_key
  end
end
