require 'date'
require 'sqlite3'
require_relative 'lib/includes.rb'

def create_database
  db_session = SQLite3Session.new( config('db_name') )
  db_session.create_db

  table_name = 'transaction'
  table_schema_raw = [
    ['transaction_id', 'INTEGER', true],
    ['series_id', 'INTEGER'],
    ['date', 'TEXT'],
    ['amount', 'INTEGER'],
    ['label', 'TEXT'],
    ['type', 'TEXT'],
    ['budget_category', 'TEXT']
  ]

  # Build and execute the table creation query.
  transaction_table_schema = SQLite3TableSchema.new(table_name)
  transaction_table_schema.parse_raw_table_data(table_schema_raw)
  query = transaction_table_schema.table_creation_query
  db_session.execute_query(query)
end

def create_one_time_transaction
  puts 'Creating one-time transaction...'
end

def create_repeating_transaction
  puts 'Creating repeating transaction...'
  puts 'How often does this transaction repeat? (y: yearly, m: monthly, w: weekly, d: daily)'
  frequency = gets.chomp.to_s

  puts 'Is this transaction income or an expense? (i/e)'
  type = gets.chomp.to_s

  puts 'Enter the dollar amount with no negative sign, no commas, and two decimal places - i.e. 102.32'
  puts 'Amount:'
  amount = gets.chomp.to_s
  amount_dollars = amount[0..-2].to_i
  amount_cents = amount[-2, 2].to_i
  puts 'Amount intepreted as:'
  numeric_amount = amount_dollars * 100
  numeric_amount += amount_cents
  numeric_amount = (numeric_amount.to_f / 100.0).to_f
  puts '$' + numeric_amount.to_s
  amount = ((amount_dollars * 100) + amount_cents).to_i

  puts 'Label:'
  label = gets.chomp.to_s

  puts 'Budget Category:'
  budget_category = gets.chomp.to_s

  puts 'Start Date: (yyyy-mm-dd)'
  start_date_input = gets.chomp.to_s
  start_date = Date.iso8601(start_date_input)

  puts 'Does this transaction have an end date? (y/n)'
  input = gets.chomp.to_s

  if( input == 'y' )
    puts 'What does the end date? (yyyy-mm-dd)'
    end_date_input = gets.chomp.to_s
    end_date = Date.iso8601(end_date_input)
  else
    puts 'Transactions with no specified end date will automatically expire after 5 years.'
    end_date_year = start_date.year + 5
    end_date = Date.new(end_date_year, start_date.month, start_date.day)
    puts "End date set to: #{end_date}"
  end

  transaction = RepeatingTransaction.new(frequency, amount, type, label, budget_category, start_date, end_date)
  transaction.display

  puts 'Confirm transaction info is correct? (y/n)'
  input = gets.chomp.to_s

  if( input == 'y' )
    transaction.write_to_database
  else
    puts 'Cancelling transaction creation process...'
  end
end

def start_transaction_creation
  puts 'Transaction Creation'
  puts 'Does this transaction repeat? (y/n)'
  input = gets.chomp.to_s

  if( input == 'y' )
    create_repeating_transaction
  else
    create_one_time_transaction
  end
end

def start_transaction_display
  puts 'Transaction List'
end

def main
  include_libraries
  puts 'Transaction Manager'
  puts '1 - Create new transaction'
  puts '2 - View all transactions'
  puts '3 - Set up database'

  input = gets.chomp.to_s

  if( input == '1' )
    puts 'Opening transaction creation menu...'
    start_transaction_creation
  elsif ( input == '2' )
    puts 'Display all transactions...'
    start_transaction_display
  elsif ( input == '3' )
    puts 'Performing first-time database setup...'
    create_database
  elsif ( input == 'q' )
    puts 'Exiting...'
    exit
  else
    puts 'Invalid menu choice'
    main
  end
end

main
