class TransactionManagerConfig
  attr_reader :db_name

  def initialize
    # Change these values to configure this application.
    @db_name = 'finance'
  end
end
