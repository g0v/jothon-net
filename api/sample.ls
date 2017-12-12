require! <[fs bluebird]>
require! <[../engine/aux]>
(engine,io) <- (->module.exports = it)  _

engine.app.get \/d/session-test/, (req, res) ->
  if !req.session.root => req.session.root = 0
  req.session.root += 1
  console.log req.session.root
  res.json {ok:req.session.root}

engine.app.get \/global, aux.type.json, (req, res) -> res.render \global.ls, {user: req.user, global: true}

# remove after forked
engine.app.get \/sample, (req, res) -> res.render 'sample/index.jade', {word1: "hello", context: {word2: "world"}}
engine.app.get \/sample.js, aux.type.json, (req, res) -> res.render 'sample/index.ls', {word: "hello world"}

engine.app.get \/, (req, res) -> res.render 'index.jade'

