class Accounts
    constructor: ->
        @fetchAccounts()

    fetchAccounts: ->
        $('.accounts').empty()
        $('.accountSelect').empty()
        $.getJSON('/account', (accounts) =>
            for account in accounts
                $('.accounts').append('<li>' + account.name + '</li>')
                $('.accountSelect').append('<option value=' + account.id + '>' + account.name + '</option>')
        )

$ ->
    window.accounts = new Accounts()
