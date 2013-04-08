update_selected = (el) ->
  $('#price-filters a.btn-inverse').removeClass('btn-inverse')
  console.log(el)
  $(el).addClass('btn-inverse')

make_link = (str) ->
  $('#' +  str.replace(/\_/g, '-') + '-link' )

$ ->
  return unless $('body.home').length > 0

  filter = $('div[data-default-filter]').data('default-filter')

  $('div[data-stat=' + filter + ']').show()
  update_selected( make_link(filter) )

  $('#mid-buy-sell-link').on('click', (e) ->
    (e).preventDefault()
    update_selected( $(this) )
    $('div[data-stat]').hide()
    $('div[data-stat=mid_buy_sell]').show()
  )

  $('#sim-buy-link').on('click', (e)->
    (e).preventDefault()
    update_selected( $(this) )
    $('div[data-stat]').hide()
    $('div[data-stat=sim_buy]').show()
  )

  $('#sim-sell-link').on('click', (e) ->
    (e).preventDefault()
    update_selected( $(this) )
    $('div[data-stat]').hide()
    $('div[data-stat=sim_sell]').show()
  )

  $('#buy-vol-link').on('click', (e) ->
    (e).preventDefault()
    update_selected( $(this) )
    $('div[data-stat]').hide()
    $('div[data-stat=buy_vol]').show()
  )

  $('#weighted-avg-link').on('click', (e) ->
    (e).preventDefault()
    update_selected( $(this) )
    $('div[data-stat]').hide()
    $('div[data-stat=weighted_avg]').show()
  )

  $('#median-link').on('click', (e) ->
    (e).preventDefault()
    update_selected( $(this) )
    $('div[data-stat]').hide()
    $('div[data-stat=median]').show()
  )

  $('#sell-vol-link').on('click', (e) ->
    (e).preventDefault()
    update_selected( $(this) )
    $('div[data-stat]').hide()
    $('div[data-stat=sell_vol]').show()
  )


