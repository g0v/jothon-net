aux = do
  insert: do
    assemble: (pairs) ->
      [cols,vals] = [[],[]]
      for k,v of pairs =>
        cols.push k
        vals.push v
      return [
        "(" + cols.join(",") + ")"
        "(" + vals.map((d,i)->"$#{i + 1}").join(",") + ")"
        vals
      ]
    format: (type, data) ->
      pairlist = {}
      for k,v of type.config.base => 
        value = switch v.type.name
        | \string  => data[k]
        | \email  => data[k]
        | \number  => data[k]
        | \date    => 
          d = new Date(data[k])
          if isNaN(d.getTime!) => new Date!toUTCString!
          else d.toUTCString!
        | \boolean => data[k]
        | \key     => data[k]
        | \array   =>
          subtype = v.type.config.type.type.name
          if subtype == \string or subtype == \number =>
            (-> 
              it = (if typeof(it) == \string => it.split \, else (it or [])).filter(->it)
              "{" + it.filter(->it?).join(",") + "}"
            ) data[k]
          else JSON.stringify(data[k])
        | otherwise  => JSON.stringify(data[k])
        pairlist[k] = (if value? => value else null)
      pairlist

module.exports = aux
