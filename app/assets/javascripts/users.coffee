$ ->
  $('table.api-keys').dataTable( {
    "iDisplayLength": 10
    "bFilter": false
    "bInfo": false
    "bLengthChange": false
    "sPaginationType": "bootstrap"
    "aaSorting": [ [0, 'asc'] ]
    "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>"
    "aoColumns": [
       null
       null
       { "bSortable": false }
       null
       { "bSortable": false }
    ]
  })

  $('#api-key-form-modal').on('show', ->
    $('#api-key-form-modal').load('/user/api_keys/new')
  )

  $('#api-key-form-modal').on('submit', 'form', (e) ->
      e.preventDefault()

      ary = $(this).serializeArray()

      key_id = $('#api-key-form-modal #api_key_key_id').val()
      vcode = $('#api-key-form-modal #api_key_vcode').val()

      jqxhr = $.post('/user/api_keys', ary, (data) ->
      )
      .error( (data) ->
        $('#api-key-form-modal').html(data.responseText)
        $('#api-key-form-modal').show()
      )
      .success( (data) ->
        $(location).attr('href','/user')
      )
  )
