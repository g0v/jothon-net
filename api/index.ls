require! <[fs path]>
require! <[./sample ./user]>
module.exports = (engine, io) ->
  user engine, io
  sample engine, io
