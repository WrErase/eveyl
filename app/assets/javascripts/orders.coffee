jQuery.fn.dataTableExt.oSort['numeric-comma-asc'] = (a,b) ->
  x = if (a == '-') then 0 else a.replace(/,/g, '')
  y = if (b == '-') then 0 else b.replace(/,/g, '')
  x = parseFloat( x )
  y = parseFloat( y )
  if (x < y) then -1 else if (x > y) then 1 else 0

jQuery.fn.dataTableExt.oSort['numeric-comma-desc'] = (a,b) ->
  x = if (a == '-') then 0 else a.replace(/,/g, '')
  y = if (b == '-') then 0 else b.replace(/,/g, '')
  x = parseFloat( x )
  y = parseFloat( y )
  if (x < y) then 1 else if (x > y) then -1 else 0

format_expires_date = (date) ->
  ts = new XDate(date)
  ts_str = ts.toUTCString("yyyy-MM-dd")

format_order_date = (date) ->
  ts = new XDate(date)
  ts_str = ts.toUTCString("yyyy-MM-dd HH:mm")

format_price = (price) ->
  retval = price.toString()
  if retval.match(/\.\d$/)
    retval += "0"
  else if not retval.match(/\.\d{2}$/)
    retval += ".00"

  retval


# URI Building
order_search_uri = (type_id, region_id, bid, high_sec) ->
  uri = "/api/orders/search.json"

  params = []
  if type_id?
    params.push 'type_id=' + type_id
  if region_id?
    params.push "region_id=" + region_id
  if bid?
    params.push 'bid=' + bid
  if high_sec?
    params.push 'high_sec=' + high_sec

  uri += '?' + params.join('&')

order_histories_uri = (type_id, region_id) ->
  uri = "/api/order_histories/search.json"

  region_id = '10000002' unless region_id?

  params = []
  if type_id?
    params.push 'type_id=' + type_id

  params.push "region_id=" + region_id

  uri += '?' + params.join('&')


histories_table_data = (sSource, aoData, fnCallback) ->
  $.getJSON( sSource, aoData, (json) ->
    aaData = []

    # TODO - Clean this up
    root = json['order_histories'][0]['regions']
    $.each(root, (key, region) ->
      region_name = region.name

      $.each(region.order_histories, (idx, obj) ->
        return if obj.outlier

        ts = new XDate(obj.ts)
        ts_str = ts.toUTCString("yyyy-MM-dd")
        aData = [region_name, ts_str]

        if obj.quantity?
          aData.push(obj.quantity)
        else
          return

        if obj.average?
          aData.push( format_price(obj.average) )
        else
          return

        if obj.low?
          aData.push( format_price(obj.low.toString()) )
        else
          aData.push('')

        if obj.high?
          aData.push( format_price(obj.high.toString()) )
        else
          aData.push('')

        aaData.push(aData)
      )
    )
    fnCallback({"aaData": aaData})
  )

build_order_link = (id) ->
  icon = $("<i>").addClass('icon-th-list')
  link = $("<a>").attr("href", "/orders/" + id)
                 .attr("target", "_blank")
                 .html(icon)


$ ->
  return unless $('body.orders').length > 0

  $('#type-input').select2({
    placeholder: 'Item Name (Tritanium)'
    minimumInputLength: 3
    ajax: {
      url: "/api/types/names.json"
      dataType: 'json'
      data: (term, page) ->
        {q: term}
      results: (data, page) ->
        new_data = {results: []}
        $.each(data, (idx, val) ->
          new_data.results.push({'text': val.name, 'id': val.type_id})
        )

        new_data
    }
  }).change( ->
    $('#type-id').val( $(this).val() )
  )

  $('#region-input').select2({
    placeholder: 'Region Name (The Forge)'
    minimumInputLength: 2
    ajax: {
      url: "/api/regions/names.json"
      dataType: 'json'
      data: (term, page) ->
        {q: term}
      results: (data, page) ->
        new_data = {results: []}
        $.each(data, (idx, val) ->
          new_data.results.push({'text': val.name, 'id': val.region_id})
        )
        new_data
    }
  }).change( ->
    $('#region-id').val( $(this).val() )
  )

  type_id = $('.sell-table').data('type_id')
  region_id = $('.sell-table').data('region_id')
  region_id = null unless region_id? && typeof region_id == 'number'
  high_sec = $('.sell-table').data('high_sec')

  $('.buy-table').dataTable( {
    "bFilter": false
    "sAjaxSource": order_search_uri(type_id, region_id, 1, high_sec)
    "iDisplayLength": 14
    "bLengthChange": false
    "bRetrieve": true
    "bServerSide": true
    "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>"
    "sPaginationType": "bootstrap"
    "aaSorting": [ [2, 'desc'], [3, 'desc']]
    "aoColumns": [
      null,
      null,
      { "sType": "numeric-comma" },
      { "sType": "numeric-comma" },
      null,
      null,
      { "bSortable": false }
    ]
    "fnRowCallback": (nRow, aData) ->
      $('td:eq(2)', nRow).html( $.commify( format_price(aData[2]) ) )
      $('td:eq(3)', nRow).html( $.commify(aData[3]) )
      $('td:eq(4)', nRow).html( format_expires_date(aData[4]) )
      $('td:eq(5)', nRow).html( format_order_date(aData[5]) )
      $('td:eq(6)', nRow).html( build_order_link(aData[6]) )

      nRow
  })


  $('.sell-table').dataTable( {
    "bFilter": false
    "sAjaxSource": order_search_uri(type_id, region_id, 0, high_sec)
    "iDisplayLength": 14
    "bLengthChange": false
    "bRetrieve": true
    "bServerSide": true
    "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>"
    "sPaginationType": "bootstrap"
    "aaSorting": [ [2, 'asc'], [3, 'desc']]
    "aoColumns": [
      null,
      null,
      { "sType": "numeric-comma" },
      { "sType": "numeric-comma" },
      null,
      null,
      { "bSortable": false }
    ]
    "fnRowCallback": (nRow, aData) ->
      $('td:eq(2)', nRow).html( $.commify( format_price(aData[2]) ) )
      $('td:eq(3)', nRow).html( $.commify(aData[3]) )
      $('td:eq(4)', nRow).html( format_expires_date(aData[4]) )
      $('td:eq(5)', nRow).html( format_order_date(aData[5]) )
      $('td:eq(6)', nRow).html( build_order_link(aData[6]) )

      nRow
  })

  $('.region-stats-table').dataTable( {
    "bFilter": false
    "bLengthChange": false
    "iDisplayLength": 14
    "sPaginationType": "bootstrap"
    "aoColumns": [
      null,
      null,
      { "sType": "numeric-comma" },
      { "sType": "numeric-comma" },
      { "sType": "numeric-comma" },
      { "sType": "numeric-comma" },
      { "sType": "numeric-comma" },
      { "sType": "numeric-comma" },
    ]
  })

  $('.history-table').dataTable( {
    "bFilter": false
    "sAjaxSource": order_histories_uri(type_id, region_id)
    "iDisplayLength": 20
    "bLengthChange": false
    "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>"
    "sPaginationType": "bootstrap"
    "aaSorting": [ [1, 'desc'], [0, 'asc'] ]
    "aoColumns": [
      null,
      null,
      { "sType": "numeric-comma" },
      { "sType": "numeric-comma" },
      { "sType": "numeric-comma" },
      { "sType": "numeric-comma" },
    ]
    "fnRowCallback": (nRow, aData) ->
      $('td:eq(3)', nRow).html( $.commify(aData[3]) )
      $('td:eq(4)', nRow).html( $.commify(aData[4]) )
      $('td:eq(5)', nRow).html( $.commify(aData[5]) )
      $('td:eq(6)', nRow).html( $.commify(aData[6]) )

      nRow

    "fnServerData": histories_table_data
  })

  $('#order-search-form').submit( (e)->
    $('#loading').hide()
    $('#error').hide()

    if not $('#type-id').val()
      $('#error strong').html("Must Select an Item")
      $('#error').show()
      e.preventDefault()

    else if $('#region-input').val() and not $('#region-id').val()
      $('#error').html("Unknown Region").show()
      e.preventDefault()
    else
      $('#loading').show()
  )
