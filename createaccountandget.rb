require './models'
require './swedbank'

#Create user
user = User.new(
    :pnr => ARGV[0],
    :pin => ARGV[1]
)

#Create swedban-scraper and fetch transactions
scraper = Swedbank.new(user)
scraper.scrapeTransactions()
