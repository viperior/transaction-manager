# Represents the schema of a SQLite3 database table.
class SQLite3TableSchema
  def initialize(table_name)
    @fields = []
    @table_name = table_name
  end

  def add_field(field_object)
    # Push a new field object to the array of fields.
    @fields.push(field_object)
  end

  def parse_raw_table_data(table_field_array)
    # Given a 2D array of field data, create field objects and store them.

    # Loop through the fields.
    table_field_array.each_with_index do |field, index|
      # Get the field data.
      field_index = index
      field_name = field[0]
      field_data_type = field[1]
      is_primary_key = field.size == 3 && field[2]

      # Set up a new field object.
      current_field = SQLite3Field.new( field_index, field_name, field_data_type, is_primary_key )

      # Add the field object to the list.
      add_field(current_field)
    end
  end

  def table_creation_query
    # Return the valid SQL statement to create this table.

    # Begin creating the table.
    sql = "CREATE TABLE IF NOT EXISTS '#{@table_name}' ("

    # Add each field definition.
    @fields.each_with_index do |field, index|
      # State the field name and data type.
      sql += "#{field.field_name} #{field.data_type}"

      # Indicate if the field is a primary key.
      sql += ' PRIMARY KEY' if field.is_primary_key

      # Close line with a comma, unless this is the last field.
      sql += ',' unless index == ( @fields.size - 1 )
    end

    # Close the table creation statement.
    sql += ');'

    return sql
  end
end
