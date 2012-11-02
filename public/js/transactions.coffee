class Transactions

    constructor: ->
        @transactions = []
        @fetchTransactions()
        $('#transactions').on('click', '.transaction', (evt) =>
            @transactionDialog(evt.target.className)
        )

    fetchTransactions: ->
        #Populate transaction list
        $('#transactions').empty()
        $.getJSON('/transactions/uncat', (transactions) =>
            for transaction in transactions
                @transactions[transaction.id] = transaction
                $('#transactions').append('<li class="transaction"><a class=' + transaction.id + '>' + transaction.receiver + ':' + transaction.amount + '</a></li>')
        )

    transactionDialog: (id)->
        trans = @transactions[id]
        dialog = $('#transactionDialog')
        dialog.find('.transactionInfo').html(
            '<table class="table">
                <tr><th>Datum</th><th>Mottagare</th><th>Summa</th></tr>
                <tr>
                <td>' + trans.date + '</td>
                <td>' + trans.receiver + '</td>
                <td>' + trans.amount + ':-</td>
                </tr>
            </table>')
        dialog.modal('show')
        dialog.find('.submit').click((evt) =>
            $.post('/transaction/' + trans.id + '/addAccount/' + dialog.find('.accountSelect').val(), (success) =>
                @fetchTransactions()
                dialog.modal('hide')
            )
        )

$ ->
    window.transactions = new Transactions()
