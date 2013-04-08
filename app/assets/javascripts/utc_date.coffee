pad = (n) ->
  n<10 ? '0'+n : n

shortUTC = (d) ->
  d.getUTCFullYear()+'-'
  + pad(d.getUTCMonth()+1)+'-'
  + pad(d.getUTCDate())+' '
  + pad(d.getUTCHours())+':'
  + pad(d.getUTCMinutes())
