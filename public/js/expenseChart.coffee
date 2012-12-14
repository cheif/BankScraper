class ExpenseChart
    constructor: ->
        @options = {
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
                stackLabels: {
                    enabled: true,
                    style: {
                        fontWeight: 'bold'
                    }
                }
            },
            legend: {
                align: 'right',
                verticalAlign: 'top',
                floating: true
            },
            tooltip: {
                formatter: ->
                    data = @series.options.detailedData[@point.x]
                    str = "<h4>" + @series.name + " - " + @x + "</h4>"
                    str += "<table><tbody><tr><th>Mottagare</th><th>Kostnad</th></tr>"
                    for trans in data
                        str += "<tr><td>" + trans.receiver + "</td><td>" + trans.amount + "</td></tr>"
                    str += "<tr><td><b>Totalt:</b></td><td>" + @y + "</td></tr>"
                    str += "</tbody></table>"
                    return str
                useHTML: true
            },
            plotOptions: {
                column: {
                    stacking: 'normal',
                    dataLabels: {
                        enabled: true,
                        color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white',
                    }
                }
            },
            series: []
        }
    
    updateChart: ->
        $.getJSON('/expenses/month', (data) =>
            @options.xAxis.categories = data.labels
            @options.series = data.series
            chart = new Highcharts.Chart(@options)
        )

$ ->
    window.expenseChart = new ExpenseChart()
