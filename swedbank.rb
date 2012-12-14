# encoding: UTF-8

require 'rubygems'
require 'mechanize'
require './models.rb'

class Swedbank
    #A scraper for swedbank
    def initialize(user)
        #initialize url, user and a new Mechanize agent, then do the login.
        @baseurl = "https://internetbank.swedbank.se"
        @user = user
        @agent = Mechanize.new
        @agent.user_agent_alias = 'Mac Safari'
        self.login()
    end

    def login()
        #Login, basically just steps through the steps of the login and posts the correct forms.
        authidpage = @agent.get(@baseurl + "/bviPrivat/privat?ns=1")
        authform = authidpage.form('form1')
        login1page = @agent.submit(authform, authform.buttons.first)
        login1form = login1page.form('auth')
        login1form['auth:kundnummer'] = @user.pnr
        login1form.field_with(:name => 'auth:metod_2').options[3].select
        login2page = @agent.submit(login1form, login1form.buttons.first)
        login2form = login2page.form('form')
        login2form['form:pinkod'] = @user.pin
        redirectpage = @agent.submit(login2form, login2form.buttons.first)
        redirectform = redirectpage.form('redirectForm')
        
        #Probably only necessary if you have multiple persons/organisations connected
        #to you internetbank
        startpage = @agent.submit(redirectform, redirectform.buttons.first)
        accountpage = startpage.link_with(:text => 'Dan Berglund').click

        transactionpage = accountpage.link_with(:text => 'Privatkonto').click
        transactionpage = transactionpage.link_with(:text => 'Visa alla').click
        while (tp = transactionpage.link_with(:text => 'Hämta fler'))
            #Fetch all transactions possible
            transactionpage = tp.click
        end
        @transactionpage = transactionpage
    end

    def scrapeTransactions()
        #scrapes all transactions and saves them in db
        #TODO Only fetch new transactions
        transactions = @transactionpage.search("//div[@class='sektion-innehall2']/table")[-1].search('.//tr')
        transactions.reverse.each{|raw_trans|
            data = raw_trans.search('.//td')
            if !data.empty? && data.length > 3
                amount = data[4].search('./span').first.content.strip
                amount = amount.gsub(/\s+/,"")
                trans = Transaction.create(
                    :date => data[0].search('./span').first.content.strip,
                    :receiver => data[2].content.strip,
                    :amount => amount.to_i,
                    :user => @user
                )
                pp trans
            end
        }
    end
end
