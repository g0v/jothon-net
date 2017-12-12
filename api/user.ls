require! <[fs fs-extra bluebird crypto read-chunk sharp]>
require! <[../engine/aux ../src/ls/config/errcode]>
(engine,io) <- (->module.exports = it)  _

api = engine.router.api
app = engine.app

api.put \/user/:id, aux.numid false, (req, res) ->
  if !req.user or req.user.key != +req.params.id => return aux.r403 res
  {displayname, description, public_email} = req.body{displayname, description, public_email}
  displayname = "#displayname".trim!
  description = "#description".trim!
  public_email = !!!public_email
  if displayname.length > 30 or displayname.length < 1 => return aux.r400 res, errcode("profile.displayname.length")
  if description.length > 200 => return aux.r400 res, errcode("profile.description.toolong")
  io.query "update users set (displayname,description,public_email) = ($1,$2,$3) where key = $4",
  [displayname, description, public_email, req.user.key]
    .then ->
      req.user <<< {displayname, description, public_email}
      req.login req.user, -> res.send!
      return null

api.put \/me/passwd/, (req, res) ->
  {n,o} = req.body{n,o}
  if !req.user or !req.user.usepasswd => return aux.r400 res
  if n.length < 4 => return aux.r400 res, errcode("profile.newPassword.length")
  io.query "select password from users where key = $1", [req.user.key]
    .then ({rows}) ->
      if !rows or !rows.0 => return aux.reject 403
      io.authio.user.compare o, rows.0.password
        .catch -> return aux.reject 403, errcode("profile.oldPassword.mismatch")
    .then -> io.authio.user.hashing n, true, true
    .then (pw-hashed) ->
      req.user <<< {password: pw-hashed}
      io.query "update users set (password) = ($1) where key = $2", [pw-hashed, req.user.key]
    .then -> req.login(req.user, -> res.send!); return null
    .catch aux.error-handler res

api.put \/me/su/:id, (req, res) ->
  if !req.user or req.user.username != engine.config.superuser => return aux.r403 res
  io.query "select * from users where key = $1", [+req.params.id]
    .then (r={})->
      if !r.rows or !r.rows.0 => return aux.reject 404
      req.user <<< r.rows.0
      req.logIn r.rows.0, -> res.send!
      return null
    .catch aux.error-handler res

