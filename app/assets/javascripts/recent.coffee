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

$ ->
  $('.recent-sell-table').dataTable( {
    "bFilter": false
    "iDisplayLength": 15
    "bLengthChange": false
    "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>"
    "sPaginationType": "bootstrap"
    "aaSorting": [ [5, 'desc'] ]
    "aoColumns": [
      null,
      null,
      null,
      { "sType": "numeric-comma" },
      { "sType": "numeric-comma" },
      null
    ]
  })

  $('.recent-buy-table').dataTable( {
    "bFilter": false
    "iDisplayLength": 15
    "bLengthChange": false
    "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>"
    "sPaginationType": "bootstrap"
    "aaSorting": [ [5, 'desc'] ]
    "aoColumns": [
      null,
      null,
      null,
      { "sType": "numeric-comma" },
      { "sType": "numeric-comma" },
      { "sType": "numeric-comma" },
      null
    ]
  })

