last = {}
base = do
  fixip: ->
    headers = <[x-forwarded-for forwarded-for]>
    (req, res, next) ->
      if req and req.socket =>
        ip = req.socket.remote-address
        for k,v of req.headers => if k.to-lower-case! in headers =>
          v = v.split \,
          if v.length => ip = v.0.trim!
        Object.define-property req, \ip, {value: ip}
      next!
  all: (req, res, next) -> base.limit((req, res, next) -> next!) req, res, next
  strategy: do
    # higher request rate, faster throttling.
    # penalty: ~ max penalty when delay = 0
    # rate: ~ min penalty when delay = lb
    default: (record, config) ->
      delta = record.now - record.last
      lb = config.lower-delta or 1
      hb = config.upper-delta or 3
      rate = config.rate or 1
      penalty = config.penalty or 2 # counting if delay = 0. 300 count needs 1 day to unlock
      limit = config.limit or 10
      if delta >= hb => 
        record.recover = recover = Math.sqrt(delta)
        if recover > record.count => record.count = 0
      if record.count > limit => return false
      if delta <= lb => record.count += rate * (lb + 0.001) / ( delta + 0.001 + (lb/penalty) )
      return true
    # hard limit
    hard: (record, config) ->
      hb = config.upper-delta or 86400
      limit = config.limit or 10
      if record.now - record.last >= hb => record.count = 0
      record.count++
      if record.count >= limit => return false
      return true

  limit: (config, func) ->
    (req, res, next) ~>
      key = (req.ip or req.socket.remoteAddress)
      if !config.isGlobal => key = "#key:#{req.url}"
      record = if !(key of last) => last[key] = {count:0, last:0} else last[key]
      record.now = new Date!getTime!/1000
      handler = @strategy[config.strategy or \default]
      if handler record, config => 
        func req, res, next
        record.last = record.now
      else 
        if config.json => return res.status 503 .json {msg: "too much request. try again later"}
        else res.status 503 .send "503 Too Much Request, Service Temporarily Unavailable"

module.exports = base
