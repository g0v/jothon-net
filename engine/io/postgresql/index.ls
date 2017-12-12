require! <[pg bluebird crypto bcrypt colors ./aux]>

ret = (config) ->
  @config = config
  @authio = authio = do
    user: do
      # store whole object ( no serialization )
      serialize: (user={}) -> bluebird.resolve( user or {} )
      deserialize: (v) ~> bluebird.resolve( v or {})

      # store only key
      #serialize: (user={}) -> bluebird.resolve( user.key or 0 )
      #deserialize: (v) ~>
      #  @query "select * from users where key = $1", [v]
      #    .then (r={}) -> r.[]rows.0

      hashing: (password, doMD5 = true, doBcrypt = true) -> new bluebird (res, rej) ->
        ret = if doMD5 => crypto.createHash(\md5).update(password).digest(\hex) else password
        if doBcrypt => bcrypt.genSalt 12, (e, salt) -> bcrypt.hash ret, salt, (e, hash) -> res hash
        else res ret

      compare: (password='', hash) -> new bluebird (res, rej) ->
        md5 = crypto.createHash(\md5).update(password).digest(\hex)
        bcrypt.compare md5, hash, (e, ret) -> if ret => res! else rej new Error!

      get: (username, password, usepasswd, detail, doCreate = false) ~>
        if !/^[-a-z0-9~!$%^&*_=+}{\'?]+(\.[-a-z0-9~!$%^&*_=+}{\'?]+)*@([a-z0-9_][-a-z0-9_]*(\.[-a-z0-9_]+)*\.[a-z]{2,}|([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}))(:[0-9]{1,5})?$/i.exec(username) =>
          return bluebird.reject new Error("not email")
        user = {}
        @query "select * from users where username = $1", [username]
          .then (users = {}) ~>
            user := (users.[]rows.0)
            if !user and !doCreate => return bluebird.reject new Error("failed")
            if !user and doCreate => return @authio.user.create username, password, usepasswd, detail
            else if user and !(usepasswd or user.usepasswd) =>
              delete user.password
              return user
            @authio.user.compare password, user.password
          .then ->
            if it => user := (if user => user else {}) <<< it
            delete user.password
            return user

      create: (username, password, usepasswd, detail = {}, config = {}) ~>
        user = null
        if !/^[-a-z0-9~!$%^&*_=+}{\'?]+(\.[-a-z0-9~!$%^&*_=+}{\'?]+)*@([a-z0-9_][-a-z0-9_]*(\.[-a-z0-9_]+)*\.[a-z]{2,}|([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}))(:[0-9]{1,5})?$/i.exec(username) =>
          return bluebird.reject new Error("not email")
        @authio.user.hashing password, usepasswd, usepasswd
          .then (pw-hashed) ~>
            displayname = if detail => detail.displayname or detail.username
            if !displayname => displayname = username.replace(/@.+$/, "")
            user := {username, password: pw-hashed, usepasswd, displayname, detail, config, createdtime: new Date!}
            @query [
              "insert into users"
              "(username,password,usepasswd,displayname,createdtime,detail,config) values"
              "($1,$2,$3,$4,$5,$6,$7) returning key"
            ].join(" "), [
              user.username, user.password, user.usepasswd,
              user.displayname, new Date!toUTCString!, user.detail, user.config
            ]
          .then (r) ~>
            key = r.[]rows.0.key
            return user <<< {key}

    session: do
      get: (sid, cb) ~>
        @query "select * from sessions where key=$1", [sid]
          .then ->
            cb null, (it.[]rows.0 or {}).detail
            return null
          .catch -> [console.error("session.get", it), cb it]
        return null
      set: (sid, session, cb) ~>
        @query([
          "insert into sessions (key,detail) values"
          "($1, $2) on conflict (key) do update set detail=$2"].join(" "), [sid, session])
          .then ->
            cb!
            return null
          .catch -> [console.error("session.set", it), cb!]
        return null
      destroy: (sid, cb) ~>
        @query "delete from sessions where key = $1", [sid]
          .then ->
            cb!
            return null
          .catch -> [console.error("session.destroy",it),cb!]
        return null
  @

ret.prototype = do
  query: (a,b=null,c=null) ->
    if typeof(a) == \string => [client,q,params] = [null,a,b]
    else => [client,q,params] = [a,b,c]
    _query = (client, q, params=null) -> new bluebird (res, rej) ->
      (e,r) <- client.query q, params, _
      if e => return rej e
      return res r
    if client => return _query client, q, params
    (res, rej) <~ new bluebird _
    (err, client, done) <~ pg.connect @config.io-pg.uri, _
    if err => return rej err
    _query client, q, params
      .then (r) -> [done!, res r]
      .catch -> [done!, rej it]
  aux: aux

module.exports = ret

