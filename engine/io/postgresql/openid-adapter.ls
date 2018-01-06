adapter = (name) ->

db = {}

adapter.prototype <<< do
  upsert: (id, payload, expiresIn) ->
  find: (id) ->
  consume: (id) ->
  destroy: (id) ->
  connect: (provider) -> console.log "adapter.connect", provider

module.exports = adapter
