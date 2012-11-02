require 'curb'
require 'nokogiri'
require 'date'
require './models.rb'

class Swedbank
    def initialize(user)
        @baseurl = "https://mobilbank.swedbank.se"
        @user = user
        self.login()
    end

    def login()
        loginpage = Curl::Easy.perform(@baseurl + "/banking/swedbank/login.html") do |curl|
            curl.headers["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.94 Safari/537.4"
        end
        noko = Nokogiri::HTML(loginpage.body_str)
        csrf_token = noko.xpath('//input[@name = "_csrf_token"]')[0]['value']

        @cookie = /Set-Cookie: (.*)/.match(loginpage.header_str)[1]
        loginresp = Curl::post(@baseurl + "/banking/swedbank/login.html", {
            :_csrf_token => csrf_token,
            :xyz => @user.pnr,
            :zyx => @user.pin
        }) do |curl|
            curl.headers['Cookie'] = @cookie
        end
        @cookie = /Set-Cookie: (.*?; )/.match(loginresp.header_str)[1]
    end

    def scrapeAccounts()
        accountpage = Curl::Easy.perform(@baseurl + "/banking/swedbank/accounts.html") do |curl|
            curl.headers['Cookie'] = @cookie
        end
        noko = Nokogiri::HTML(accountpage.body_str)
        accountList = []
        noko.xpath('//dd/a').each{ |acc|
            account = Bankaccount.create(
                :name => acc.xpath('span[@class="name"]').first.content,
                :href => acc['href'],
                :balance => acc.xpath('span[@class="amount"]').first.content.gsub(/\s/,"").to_i,
                :user => @user
            )
            accountList << account
        }
        return accountList
    end

    def scrapeTransactions(account)
        newest = account.transactions.last
        last = nil
        cont = true
        while cont
            accountpage = Curl::Easy.perform(@baseurl + account.href + "&action=next") do |curl|
                curl.headers['Cookie'] = @cookie
            end
            noko = Nokogiri::HTML(accountpage.body_str)
            noko.xpath('//dl[@class = "list-content"]//div').each{ |transaction|
                receiver = transaction.xpath('span[@class="receiver"]')
                if receiver.to_s != "" && receiver.first.content.strip != "SKYDDAT BELOPP"
                    amount = transaction.xpath('span[@class="amount"]').first.content.strip
                    amount = amount.gsub(/\s+/,"")
                    trans = Transaction.create(
                        :date => Date.parse(transaction.xpath('span[@class="date"]').first.content.strip),
                        :receiver => receiver.first.content.strip,
                        :amount => amount.to_i,
                        :bankaccount => account
                    )
                    puts trans.inspect
                    #Need this check since &action=next will give circular results
                    if trans == newest or (last && last.date < trans.date)
                        cont = false
                        break
                    end
                    last = trans
                end
            }
        end
    end
end
