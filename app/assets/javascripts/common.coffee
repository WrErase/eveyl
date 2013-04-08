$ ->
  $("a[rel=tooltip]").tooltip()

  $("img").on("error", (e) ->
      $(e.target).hide()
  )
