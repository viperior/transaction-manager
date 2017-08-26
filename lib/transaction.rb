class Transaction
  attr_writer :series_id

  def initialize(amount, type, label, budget_category, date)
    @amount = amount
    @budget_category = budget_category
    @date = date
    @label = label
    @series_id = nil
    @type = type
  end

  def amount_decimal
    return (@amount.to_f / 100.0).to_f
  end

  def date_db_value
    return @date.to_s
  end

  def debug
    puts '- - -'
    puts @amount
    puts @budget_category
    puts @date
    puts @label
    puts @series_id
    puts @type
    puts amount_decimal
    puts date_db_value
    puts series_id_db_value
    puts type_label
    puts '- - -'
  end

  def display
    puts "\nTransaction info"
    puts "Date: #{@date}\n"
    puts "Label: #{@label}"
    puts "Amount: $#{amount_decimal}"
    puts "Type: #{type_label}"
    puts "Budget category: #{@budget_category}"
    puts "Series ID: #{@series_id}"
  end

  def series_id_db_value
    if( @series_id.nil? )
      return 'NULL'
    else
      return @series_id.to_s
    end
  end

  def type_label
    if( @type == 'i' )
      return 'income'
    elsif ( @type == 'e' )
      return 'expense'
    end
  end

  def write_to_database
    debug
    db_session = SQLite3Session.new('finance')
    query = "INSERT INTO 'transaction' (series_id, date, amount, label, type, budget_category) VALUES (#{series_id_db_value}, '#{date_db_value}', #{@amount}, '#{@label}', '#{@type}', '#{@budget_category}');"
    db_session.execute_query(query)
  end
end
