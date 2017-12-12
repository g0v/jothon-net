# This file should be served only if server is down, and should never be minimized.
# when server is alive, engine/index.ls serves another global.js.
(->
  req = {static: true}
  if angular? => if window._backend_ => angular.module(\backend) else angular.module(\backend, <[]>)
    ..factory \global, <[]> ++ -> req
)!
