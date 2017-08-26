class RepeatingTransaction < Transaction
  def initialize(frequency, amount, type, label, budget_category, start_date, end_date)
    @amount = amount
    @budget_category = budget_category
    @end_date = end_date
    @frequency = frequency
    @label = label
    @series = []
    @series_id = nil
    @start_date = start_date
    @type = type
  end

  def create_series
    puts "Creating series..."

    # Create series ID
    # Query database to determine if any series are defined, and if so, what the highest ID is
    query = "SELECT COUNT(*) AS series_count FROM 'transaction' WHERE series_id IS NOT NULL;"
    db_session = SQLite3Session.new('finance')
    db_session.execute_query(query)
    result_hash = db_session.result_hash
    series_count = result_hash.keys[0]['series_count'].to_i

    puts "# of series id's detected in database: #{series_count}"

    if( series_count > 0 )
      # Detect max series_id
      query = "SELECT MAX(series_id) AS max_series_id FROM 'transaction';"
      db_session = SQLite3Session.new('finance')
      db_session.execute_query(query)
      result_hash = db_session.result_hash
      max_series_id = result_hash.keys[0]['max_series_id'].to_i
      new_series_id = max_series_id + 1
    else
      new_series_id = 1
    end

    puts "New series id: #{new_series_id}"

    @series_id = new_series_id

    # Create transactions based on specified frequency.
    first_occurrence = Transaction.new(@amount, @type, @label, @budget_category, @start_date)
    first_occurrence.series_id = @series_id
    @series.push(first_occurrence)
    previous_date = @start_date

    loop do
      if( @frequency == 'y' )
        next_date = Date.new(previous_date.year + 1, previous_date.month, previous_date.day)
      elsif ( @frequency == 'm' )
        next_date = previous_date.next_month
      elsif ( @frequency == 'w' )
        next_date = previous_date + 7
      elsif ( @frequency == 'd' )
        next_date = previous_date.next_day
      end

      break if ( next_date > @end_date )

      current_transaction = Transaction.new(@amount, @type, @label, @budget_category, next_date)
      current_transaction.series_id = @series_id
      @series.push(current_transaction)
      previous_date = next_date
    end
  end

  def display
    puts "\nTransaction info"
    puts "Label: #{@label}"
    puts "Frequency: #{frequency_label}"
    puts "Start date: #{@start_date}"
    puts "End date: #{end_date_label}"
    puts "Amount: $#{amount_decimal}"
    puts "Type: #{type_label}"
    puts "Budget category: #{@budget_category}"
  end

  def end_date_label
    if( @end_date == false )
      return 'no end date'
    else
      return @end_date
    end
  end

  def frequency_label
    if( @frequency == 'y' )
      return 'yearly'
    elsif ( @frequency == 'm' )
      return 'monthly'
    elsif ( @frequency == 'w' )
      return 'weekly'
    elsif ( @frequency == 'd' )
      return 'daily'
    end
  end

  def write_to_database
    puts 'Writing transaction series to database...'
    create_series

    @series.each do |transaction|
      transaction.write_to_database
    end

    puts 'Transaction series successfully written to database...'
  end
end
