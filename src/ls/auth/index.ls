<- $(document).ready
auth = (node) ->
  @ <<< do
    data: email: '', passwd: '', displayname: '', newsletter: true
    comps: {}
    node: node

  comps = @node.querySelectorAll '*[data-comp]'
  for comp in comps => @comps[comp.getAttribute('data-comp')] = comp
  <[email passwd displayname]>.map (n) ~>
    node = @comps[n].querySelector('input')
    node.addEventListener \input, ~> @data[n] = node.value

auth.prototype = do
  login: ->
  signup: ->

nodes = document.querySelectorAll '*[data-controller=auth]'
for node in nodes => new auth node

