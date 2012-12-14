require 'rubygems'
require 'data_mapper'

#DataMapper::Logger.new($stdout, :debug)

DataMapper.setup(:default, "sqlite://#{File.expand_path(File.dirname(__FILE__))}/test.db")

class User
    #A user, with login to internetbank
    include DataMapper::Resource

    property :id,       Serial
    property :pnr,      String
    property :pin,      String

    has n, :accounts
    has n, :transactions
end

class Account
    #Representation of booking-accounts
    include DataMapper::Resource

    property :id,       Serial
    property :name,     String

    belongs_to :user
    has n, :transactions
    has n, :filters
end

class Filter
    #Filter used for automatic categorization through regex
    include DataMapper::Resource

    property :id,       Serial
    property :regexp,   String

    belongs_to :account

end

class Transaction
    #A transaction, our main data-type
    include DataMapper::Resource

    property :id,       Serial
    property :receiver, String
    property :amount,   Integer
    property :date,     DateTime

    belongs_to :user
    belongs_to :account, :required => false

    def self.noAccount
        #Return all transactions that haven't got a account associated yet.
        all(:account => nil)
    end

    def self.hasAccount
        #Return all transactions that have a account associated.
        all(:account.not => nil)
    end

    def apply(filterList)
        #Apply filters to this account, add a account if a filter-match is found.
        filterList.each{|filter|
            reg = /^#{filter.regexp}$/i
            p self.receiver
            if reg.match(self.receiver)
                self.account = filter.account
                self.save
                break
            end
        }
    end
end

DataMapper.finalize
DataMapper.auto_upgrade!
