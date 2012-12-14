class Accounts
    constructor: ->
        @accounts = []
        @fetchAccounts()
        $('#accounts').on('click', '.account', (evt) =>
            @accountDialog(evt.target.className)
        )

    fetchAccounts: ->
        $.getJSON('/accounts', (accounts) =>
            for account in accounts
                @accounts[account.id] = account
            @populateDropdown()
            @populateDialog()
        )

    populateDropdown: ->
        $('#accounts').empty()
        for account in @accounts
            if account
                $('#accounts').append('<li class="account"><a class=' + account.id + '>' + account.name + '</a></li>')
        $('#accounts').append('<li class="account"><a class="newAccount">Lägg till konto..</a></li>')
    
    populateDialog: ->
        $('.accountSelect').empty()
        for account in @accounts
            if account
                $('.accountSelect').append('<option value=' + account.id + '>' + account.name + '</option>')

    accountDialog: (id) ->
        dialog = $('#accountDialog')
        dialog.find('tbody').empty()
        if id == "newAccount"
            name = "Nytt konto"
        else
            name = @accounts[id].name
            $.getJSON('/accounts/' + id, (accountData) =>
                filterTable = ""
                for filter in accountData.filters
                    filterTable +=
                        '<tr><td><input type="text" value=' + filter.regexp + '></td><td hidden class="id">' + filter.id + '</td></tr>'
                filterTable += '<tr><td><input class="newFilter" type="text" value="Nytt filter"></td><td hidden class="id">new</td></tr>'
                dialog.find('tbody').html(filterTable)
#TODO Instant filter-testing
            )
        dialog.find('.name').val(name)
        dialog.modal('show')
        dialog.find('.submit').click((evt) =>
            filters = []
            for filter in dialog.find('tbody tr')
                if $(filter).find('input').val() != "Nytt filter"
                    filters.push {
                        id: $(filter).find('.id').html()
                        regexp: $(filter).find('input').val()
                    }

            accountData = {
                'filters': filters
                'name': dialog.find('.name').val()
            }
            $.post('/accounts/' + id, accountData, (success) =>
                #FIXME Seems to be double-posting this, sometimes with wrong id
                @fetchAccounts()
                window.expenseChart.updateChart()
                window.transactions.fetchTransactions()
                dialog.modal('hide')
            )
        )

$ ->
    window.accounts = new Accounts()
