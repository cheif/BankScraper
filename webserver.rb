require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'haml'
require 'json'
require 'sass'
require 'rack/coffee'
require './models.rb'

use Rack::Coffee,
    :root => 'public',
    :urls => '/js'

get '/sass/default.sass' do
    sass :default
end

get '/' do
    haml :index
end

get '/transactions/uncat' do
    #Return transactions without accounts associated
    @user = User.first
    withoutAccount = @user.transactions.noAccount()
    withoutAccount.to_json
end

post '/transactions/addAccount/' do
    #Add the account to the transactions
    @user = User.first
    for id in params[:ids]
        trans = @user.transactions.get(id)
        trans.account = @user.accounts.get(params[:account])
        trans.save
    end
end

get '/expenses/month' do
    #Return expenses(and incomes) grouped by account and month, in a format good for highcharts.
    @user = User.first
    #TODO Filter start & end date
    expenses = @user.accounts.transactions.all(:order => [:date.asc])
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
                    account[:data][month].inject(0){|sum, trans| sum + trans.amount}
                else
                    #nil won't be plotted in highcharts
                    nil
                end
            },
            :detailedData =>
            response[:labels].map{|month|
                if account[:data][month]
                    account[:data][month]
                else
                    0
                end
            },
        }
    }
    response.to_json
end

get '/accounts' do
    #Return all accounts for current user
    @user = User.first
    @user.accounts.to_json
end

get '/accounts/:id' do
    #Return data for account with :id
    @user = User.first
    account = @user.accounts.get(params[:id])
    account =
        {
            :name => account.name,
            :id => account.id,
            :filters => account.filters
        }
    account.to_json
end

post '/accounts/:id' do
    #Update account with :id
    @user = User.first
    if params[:id] == 'newAccount'
        #Create account
        account = Account.create(
            :user => @user,
            :name => params[:name]
        )
    else
        account = Account.get(params[:id])
        account.name = params[:name]
        account.save
    end
    if params[:filters]
        params[:filters].each{|_, filter|
            if filter[:id] != 'new'
                f = account.filters.get(filter[:id])
                f.regexp = filter[:regexp]
                f.save
            else
                f = Filter.create(
                    :account => account,
                    :regexp => filter[:regexp]
                )
            end
        }
    end
    #Run filters
    withoutAccount = @user.transactions.noAccount()
    filters = account.filters
    withoutAccount.each{|transaction|
        transaction.apply(filters)
    }
    return nil
end
