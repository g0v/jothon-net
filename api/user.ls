require! <[fs fs-extra bluebird crypto read-chunk sharp]>
require! <[../engine/aux ../src/ls/config/errcode]>
uuidv4 = require "uuid/v4"

(engine,io) <- (->module.exports = it)  _

api = engine.router.api
app = engine.app

api.put \/user/:id, aux.numid false, (req, res) ->
  if !req.user or req.user.key != +req.params.id => return aux.r403 res
  {displayname, description, public_email, config} = req.body{ displayname, description, public_email, config }
  displayname = "#displayname".trim!
  description = "#description".trim!
  public_email = !!!public_email
  if displayname.length > 30 or displayname.length < 1 => return aux.r400 res, errcode("profile.displayname.length")
  if description.length > 500 => return aux.r400 res, errcode("profile.description.toolong")
  io.query "update users set (displayname,description,public_email,config) = ($1,$2,$3,$4) where key = $5",
  [displayname, description, public_email, config, req.user.key]
    .then ->
      req.user <<< {displayname, description, public_email, config}
      req.login req.user, -> res.send!
      return null

api.put \/me/passwd/, (req, res) ->
  if !req.user or !req.user.usepasswd or !req.body => return aux.r400 res
  {n,o} = req.body{n,o}
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

api.delete \/me/jothon-app/:key, (req, res) ->
  if !req.user or !req.user.key or !req.body => return aux.r400 res
  if !req.params.key => return aux.r400 res
  io.query "update app set (deleted) = (true) where key = $1", [+req.params.key]
    .then -> io.query "select app_id from app where key = $1", [+req.params.key]
    .then (r={}) ->
      if !r.rows or !r.rows.0 => return null
      io.query "delete from oidcmodel where id = $1", [+req.params.key]
    .then -> res.send!
    .catch aux.error-handler res

update-app = (req, res, app) ->
  io.query "select key from oidcmodel where id = $1", [app.client_id]
    .then (r={}) ->
      if !r.rows or !r.rows.length =>
        io.query "insert into oidcmodel (id,payload) values ($1, $2)", [app.client_id, app]
      else => io.query "update oidcmodel set payload = $2 where id = $1", [app.client_id, app]
    .then -> res.send!
    .catch aux.error-handler res

api.put \/me/jothon-app/:key, (req, res) ->
  if !req.user or !req.user.key or !req.body => return aux.r400 res
  if !req.params.key => return aux.r400 res
  {name, callback, avatar} = req.body{name, callback, avatar}
  io.query("update app set (name, callback, avatar) = ($1, $2, $3) where key = $4",
  [name, callback, avatar, +req.params.key])
    .then -> io.query "select app_id, app_secret, callback from app where key = $1", [+req.params.key]
    .then (r={}) ->
      if !r.rows or !r.rows.length => return aux.reject 404
      item = r.rows.0
      update-app req, res, do
        name: name, avatar: avatar, redirect_uris: [callback]
        client_id: item.app_id, client_secret: item.app_secret
    .then -> res.send!
    .catch aux.error-handler res

api.post \/me/jothon-app/, (req, res) ->
  if !req.user or !req.user.usepasswd or !req.body => return aux.r400 res
  {name, callback, avatar} = req.body{name, callback, avatar}
  key = crypto.randomBytes 48
  iv = crypto.randomBytes 48
  (e,key) <- crypto.pbkdf2 key, iv, 100000, 32, 'sha512'
  if e => return aux.r500 res
  app_id = uuidv4!
  app_secret = key.toString \base64
  io.query(
  "insert into app (name,callback,avatar,app_id,app_secret,owner) values ($1, $2, $3, $4, $5, $6)"
  [name, callback, avatar, app_id, app_secret, req.user.key])
    .then -> update-app req, res, {client_id: app_id, client_secret: app_secret, redirect_uris: [callback]}
    .then -> res.send!
    .catch aux.error-handler res

api.get \/me/jothon-app/, aux.need-token, (req, res) ->
  key = req.{}auth.key or req.{}user.key
  if !key => return aux.r403 res
  io.query("select * from app where owner = $1 and deleted is not true", [key])
    .then -> res.send it.[]rows
    .catch aux.error-handler res
