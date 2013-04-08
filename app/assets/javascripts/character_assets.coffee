jQuery.fn.dataTableExt.oSort['numeric-comma-asc'] = (a,b) ->
  x = if (a == '-') then 0 else a.replace(/,|%/g, '')
  y = if (b == '-') then 0 else b.replace(/,|%/g, '')
  x = parseFloat( x )
  y = parseFloat( y )
  if (x < y) then -1 else if (x > y) then 1 else 0

jQuery.fn.dataTableExt.oSort['numeric-comma-desc'] = (a,b) ->
  x = if (a == '-') then 0 else a.replace(/,|%/g, '')
  y = if (b == '-') then 0 else b.replace(/,|%/g, '')
  x = parseFloat( x )
  y = parseFloat( y )
  if (x < y) then 1 else if (x > y) then -1 else 0

$ ->
  return unless $('body.character_assets').length > 0

  $('.assets-table').dataTable( {
    "bFilter": false
    "iDisplayLength": 15
    "bLengthChange": false
    "bRetrieve": true
    "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>"
    "sPaginationType": "bootstrap"
    "aaSorting": [ [0, 'asc'] ]
    "aoColumns": [
      null
      null
      { "sType": "numeric-comma" }
      null
      null
      null
      { "sType": "numeric-comma" }
      null
    ]
    "fnDrawCallback": ->
      console.log( $(this).parent().children().find('.dataTables_paginate ul li').size() )
      if $(this).parent().children().find('.dataTables_paginate ul li').size() > 3
        $(this).parent().children().find('.dataTables_info').show()
        $(this).parent().children().find('.dataTables_paginate').show()
      else
        $(this).parent().children().find('.dataTables_info').hide()
        $(this).parent().children().find('.dataTables_paginate').hide()
  })
