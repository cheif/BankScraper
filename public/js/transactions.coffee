class Transactions
    #Represents transactions

    constructor: ->
        #Construct and fetch transactions
        @uncatTransactions = []
        @fetchTransactions()
        $('#transactions').on('click', '.transaction', (evt) =>
            @transactionDialog(evt.target.className)
        )

    fetchTransactions: ->
        #Populate transaction list
        $('#transactions').empty()
        $.getJSON('/transactions/uncat', (transactions) =>
            for transaction in transactions
                #Ugly but works
                transaction.date = transaction.date.split('T')[0]
                @uncatTransactions[transaction.id] = transaction
                $('#transactions').append('<li class="transaction"><a class=' + transaction.id + '>' + transaction.receiver + ':' + transaction.amount + '</a></li>')
            $('.transcount').html('('+transactions.length+')')
        )

    doRegex: (regEx)->
        #Return transactions which matches the regex
        regex = new RegExp('^'+regEx+'$', 'i')
        res = []
        for trans in @uncatTransactions
            if trans and regex.test(trans.receiver)
                res.push trans
        return res

    findSimilar: (transaction)->
        #Return transactions similar to this one
        return @doRegex(transaction.receiver)

    transactionDialog: (id)->
        #Populate and show the transaction dialog
        trans = @uncatTransactions[id]
        transactionTable = ""
        for transaction in @findSimilar(trans)
            transactionTable += 
                '<tr>
                <td>' + transaction.date + '</td>
                <td>' + transaction.receiver + '</td>
                <td>' + transaction.amount + ':-</td>
                <td><input type="checkbox" name="use" checked></input></td>
                <td hidden class="id">' + transaction.id + '</td>
                </tr>'

        transactionTable += '</table>'
        dialog = $('#transactionDialog')
        dialog.find('.transactionInfo tbody').html(transactionTable)
        dialog.modal('show')
        dialog.find('.submit').click((evt) =>
            transactions = []
            for transaction in dialog.find('.transactionInfo tbody tr')
                if $(transaction).find('input').is(':checked')
                    transactions.push $(transaction).find('.id').html()

            transactionData = {
                'ids': transactions
                'account': dialog.find('.accountSelect').val()
            }
            $.post('/transactions/addAccount/', transactionData, (success) =>
                @fetchTransactions()
                window.expenseChart.updateChart()
                dialog.modal('hide')
            )
        )

$ ->
    window.transactions = new Transactions()
