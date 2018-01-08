modal = (dom, data) ->
  dom["mask"].addEventListener \click, ->
    helper.remove-class dom.root, 'active'
    helper.add-class dom.root, 'inactive'

modal
  ..controller = 'modal'
