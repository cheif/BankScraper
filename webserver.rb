require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'haml'
require 'sass'
require 'rack/coffee'
require './models.rb'

use Rack::Coffee,
    :root => 'public',
    :urls => '/js'

get '/' do
    haml :index
end

get '/transactions' do
    @user = User.first
    withoutAccount = @user.bankaccounts.transactions.noAccount()
    filters = @user.accounts.filters
    withoutAccount.each{|transaction|
        transaction.apply(filters)
    }
    @user.bankaccounts.transactions.to_json
end

get '/transactions/uncat' do
    @user = User.first
    withoutAccount = @user.bankaccounts.transactions.noAccount()
    filters = @user.accounts.filters
    withoutAccount.each{|transaction|
        transaction.apply(filters)
    }
    withoutAccount.to_json
end

post '/transaction/:id/addAccount/:accid' do
    @user = User.first
    trans = @user.bankaccounts.transactions.get(params[:id])
    trans.account = @user.accounts.get(params[:accid])
    trans.save
end

get '/expenses' do
    @user = User.first
    expenses = @user.bankaccounts.transactions.expenses.hasAccount
    expenses.to_json
end

get '/expenses/month' do
    @user = User.first
    expenses = @user.accounts.transactions.all(:order => [:date.asc]).expenses
    response = {}
    response[:labels] = expenses.group_by{|post|
        post.date.strftime("%b %Y")
    }.keys
    expenses = expenses.group_by{|post|
        post.account.name
    }
    expenses = expenses.map{|id, account|
        {
            :name => id,
            :data =>
            account.group_by{|post|
                post.date.strftime("%b %Y")
            }
        }
    }
    response[:series] = expenses.map{|account|
        {
            :name => account[:name],
            :data =>
            response[:labels].map{|month|
                if account[:data][month]
                    account[:data][month].inject(0){|sum, trans| sum - trans.amount}
                else
                    0
                end
            }
        }
    }
    response.to_json
end

post '/account/:name' do
    @user = User.first
    @account = Account.create(:name => params[:name], :user => @user)
    @account.to_json
end

get '/account' do
    @user = User.first
    @user.accounts.to_json
end

post '/filter/:accountId/:filterRegexp' do
    @user = User.first
    @account = @user.accounts.get(params[:accountId])
    regexp = params[:filterRegexp]
    filter = Filter.create(:account => @account, :regexp => regexp)
    puts filter.inspect
end

get '/filter' do
    @user = User.first
    @user.accounts.filters.to_json
end

get '/sass/default.sass' do
    sass :default
end
