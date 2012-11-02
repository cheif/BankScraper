require 'rubygems'
require 'data_mapper'

DataMapper::Logger.new($stdout, :debug)

DataMapper.setup(:default, "sqlite://#{File.expand_path(File.dirname(__FILE__))}/test.db")

class User
    include DataMapper::Resource

    property :id,       Serial
    property :pnr,      String
    property :pin,      String

    has n, :bankaccounts
    has n, :accounts
end

class Bankaccount
    #Representation of the banks accounts
    include DataMapper::Resource

    property :id,       Serial
    property :name,     String
    property :href,     String
    property :balance,  Integer

    belongs_to :user
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
    #Filter receiver to select appropriate account
    include DataMapper::Resource

    property :id,       Serial
    property :regexp,   String

    belongs_to :account

end

class Transaction
    include DataMapper::Resource

    property :id,       Serial
    property :receiver, String
    property :amount,   Integer
    property :date,     DateTime

    belongs_to :bankaccount
    belongs_to :account, :required => false

    def self.noAccount
        all(:account => nil)
    end

    def self.hasAccount
        all(:account.not => nil)
    end

    def self.expenses
        all(:amount.lt => 0)
    end

    def apply(filterList)
        filterList.each{|filter|
            reg = /#{filter.regexp}/i
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
