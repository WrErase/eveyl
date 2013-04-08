chart1 = null

remap_histories = (data) ->
  regions = {}
  $.each(data['order_histories'][0]['regions'], (key, val) ->
    points = []
    $.each(val['order_histories'], (oh_key, oh_val) ->
      ts = (new Date(oh_val.ts)).getTime()
      points.push( [ts, oh_val.average] )
    )
    regions[val.name] = points
  )

  regions


$ ->
  return unless $("body.orders").length > 0

  type_id = $('#chart-container').data('type_id')
  return unless type_id?

  url = '/api/order_histories/search.json?type_id=' + type_id

#  regions = {}
  $.getJSON url, (data) ->
    regions = remap_histories(data)
    $.each(regions, (key, val) ->
      val.sort (a, b) ->
        return if a[0] >= b[0] then 1 else -1
    )

    chart1 = new Highcharts.StockChart({
      chart : {
        renderTo : 'chart-container'
        type: 'scatter'
        zoomType: 'x'
      },

      rangeSelector : {
        selected : 2
      },

      title : {
        text : name + " (Daily Average)"
      },

      yAxis: {
        title: {
          text: 'Average Price'
        }
      },

      tooltip: {
        formatter: ->
          str = Highcharts.dateFormat('%b %e, %Y', this.x) + "<br />"
          $.each( this.points, (idx, val) ->
            console.log(val)
            name = val.point.series.name
            y = val.point.y
            str += "<b>" + name + "</b> - " + y + "<br />"
            console.log(str)
          )
          str
      }

      series : [{
        name : 'The Forge'
        data : regions['The Forge']
        lineWidth: 0
        marker: {
          enabled: true
          radius: 2
        }
        tooltip: {
          valueDecimals: 2
        }
      },
      {
        name : 'Metropolis'
        data : regions['Metropolis']
        lineWidth: 0
        marker: {
          enabled: true
          radius: 2
        }
        tooltip: {
          valueDecimals: 2
        }
      },
      {
        name : 'Domain',
        data : regions['Domain']
        lineWidth: 0
        marker: {
          enabled: true
          radius: 2
        }
        tooltip: {
          valueDecimals: 2
        }
      },
      {
        name : 'Heimatar'
        data : regions['Heimatar']
        lineWidth: 0
        marker: {
          enabled: true
          radius: 2
        }
        tooltip: {
          valueDecimals: 2
        }
      }]
    })
