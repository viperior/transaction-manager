# Represents a SQLite3 session for a single database. Create the database,
# execute queries, and fetch data.
class SQLite3Session
  attr_reader :result_hash

  def initialize(db_name)
    @db_name = db_name
    @result = nil
    @result_hash = {}
  end

  def create_db
    # Creates a new database.
    begin
      # Create a new database.
      db = SQLite3::Database.new(@db_name)
    rescue SQLite3::Exception => e
      # Display the error message upon error.
      p "Exception occurred while attempting to create database..."
      p e
    ensure
      # Make sure to close the database.
      db.close if db
    end
  end

  def execute_query(query)
    # Executes a query and returns the result.
    begin
      # Open the database
      db = SQLite3::Database.open(@db_name)
      db.results_as_hash = true

      # Prepare the SQL statement
      sql_statement = db.prepare(query)

      # Execute the statement and store the result.
      @result = sql_statement.execute

      @result.each { |key, value|
        @result_hash[key] = value
      }
    rescue SQLite3::Exception => e
      # Display the error message upon error.
      p "Exception occurred while querying database..."
      p e
    ensure
      # Make sure to close the database.
      sql_statement.close if sql_statement
      db.close if db
    end
  end
end
