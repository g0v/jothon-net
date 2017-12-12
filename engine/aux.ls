require! <[bluebird moment moment-timezone]>

base = do
  eschtml: (->
    map = {'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&#34;', "'": '&#39;'}
    (str) -> str.replace(/&<>'"]/g, (-> map[it]))
  )!

  log: (req, msg, head = "") ->
    date = moment(new Date!).tz("Asia/Taipei").format("MM-DD HH:mm")
    console.log "[#date|#head#{if head and req => ' ' else ''}#{if req => req.user.key else ''}] #msg"
  pad: (str="", len=2,char=' ') ->
    [str,char] = ["#str","#char"]
    "#char" * (len - str.length) + "#str"
  error: (code=403,msg="") -> new Error(msg) <<< {code}
  reject: (code=403,msg="") ->
    bluebird.reject new Error(if typeof(msg) == typeof({}) => JSON.stringify(msg) else msg) <<< {code}

  now-tag: ->
    d = new Date!
    return "#{d.getYear!}".substring(1,3) +
    "/#{base.pad(d.getMonth! + 1,2,\0)}" +
    "/#{base.pad(d.getDate!,2,\0)}" +
    " #{base.pad(d.getHours!,2,\0)}" +
    ":#{base.pad(d.getMinutes!,2,\0)}" +
    ":#{base.pad(d.getSeconds!,2,\0)}"
  #TODO use error-handler in every promise.catch
  error-handler: (res,as-page=false) -> (e={}) ->
    if typeof(e.code) == \number =>
      if as-page and base["r#{e.code}"] => base["r#{e.code}"] res, e.message, as-page
      else res.status e.code .send e.message
    else
      console.error "[#{base.now-tag!}] #{e.stack or e}"
      if as-page => base.r403 res, "sorry.", as-page
      else res.status 403 .send!
    return null

  r500: (res, error) ->
    console.log "[ERROR] #error"
    res.status(500).json({detail:error})
  r404: (res, msg = "", as-page = false) ->
    if as-page => res.status(404).render 'err/404.jade', {msg: msg}
    else res.status(404)send msg
    return null
  r403: (res, msg = "", as-page = false) ->
    if as-page => res.status(403).render 'err/403.jade', {msg: msg}
    else res.status(403)send msg
    return null
  r413: (res, msg = "", as-page = false) ->
    if as-page => res.status(413).render 'err/400.jade', {msg: msg}
    else res.status(413)send msg
    return null
  r402: (res, msg = "", as-page = false) ->
    if as-page => res.status(402).render 'err/400.jade', {msg: msg}
    else res.status(402)send msg
    return null
  r400: (res, msg = "", as-page = false) ->
    if as-page => res.status(400).render 'err/400.jade', {msg: msg}
    else res.status(400)send msg
    return null
  r200: (res) -> res.send!
  type:
    json: (req, res, next) ->
      res.set('Content-Type', 'application/json')
      next!

  numid: (as-page, cb) -> (req, res) ->
    if !/^\d+$/.exec(req.params.id) => return base.r400 res, "incorrect key type", as-page
    cb req, res

  numids: (as-page, names=[], cb) -> (req, res) ->
    if names.filter(-> !/^\d+$/.exec(req.params[it])).length => return base.r400 res, "incorrect key type", as-page
    cb req, res

  authorized: (cb) -> (req, res) ->
    if not (req.user and req.user.staff == 1) =>
      return res.status(403).render('403', {url: req.originalUrl})
    cb req, res

  needlogin: (cb) -> (req, res) ->
    if not (req.user) => return res.status(403).render('403', {url: req.originalUrl})
    cb req, res

  merge-config: (a,b) ->
    for k,v of b =>
      if a[k] and typeof(a[k]) == typeof({}) => base.merge-config(a[k], b[k])
      else => a[k] = b[k]
    a

module.exports = base
