require! <[bluebird fs-extra]>
require! <[./secret ./engine ./engine/aux ./engine/io/postgresql ./api ./api/ext]>
config = require "./config/site/#{secret.config}"

config = aux.merge-config config, secret

bluebird.config do
  warnings: true
  longStackTraces: true
  cancellation: true
  monitoring: true

pgsql = new postgresql config

engine.init config, pgsql.authio, (-> ext engine, pgsql)
  .then ->
    engine.app.get \/, (req, res) -> res.render 'index.jade'
    api engine, pgsql
    engine.app.use (req, res, next) ~> aux.r404 res, "", true
    engine.start!
  .catch ->
    console.log "[Exception] ", it.stack
