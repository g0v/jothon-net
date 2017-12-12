(->
  errcode = (str, option) ->
  if angular? =>
    try
      backend = angular.module \loadingIO
    catch e
      backend = angular.module \loadingIO, <[]>
    backend
      ..factory \errcode, <[]> ++ -> errcode
  else if module? => module.exports = errcode
)!

