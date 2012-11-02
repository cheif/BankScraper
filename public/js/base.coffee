$ ->
    $('#createAccount').click((evt) =>
        console.log "Skapar " + $('#accountName').val()
        $.post('/account/' + $('#accountName').val(), (data) =>
        ))

    $.getJSON('/filter', (filters) =>
        for filter in filters
            $('#filters').append('<li>' + filter.regexp + '</li>')
    )

    options = {
        chart: {
            renderTo: 'expenses',
            type: 'column'
        },
        title: {
            text: 'Utgifter'
        },
        xAxis: {
            categories: []
        },
        yAxis: {
            title: {
                text: 'SEK'
            },
        },
        plotOptions: {
            column: {
                stacking: 'normal',
                dataLabels: {
                    enabled: true,
                    color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
                }
            }
        },
        series: []
    }

    $.getJSON('/expenses/month', (data) =>
        options.xAxis.categories = data.labels
        options.series = data.series
        console.log options
        chart = new Highcharts.Chart(options)
    )
        


    $('#createFilter').click((evt) =>
        $.post('/filter/' + $('#filterAccount').val() + '/' + $('#filterRegexp').val())
    )
    
