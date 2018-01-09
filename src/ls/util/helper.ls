helper = do
  add-class: (node, cls) ->
    node.setAttribute \class, node.getAttribute(\class).split(' ').filter(->it != cls).join(' ') + " #cls"
  remove-class: (node, cls) ->
    node.setAttribute \class, node.getAttribute(\class).split(' ').filter(->it != cls).join(' ')
  toggle-class: (node, cls, toggle) ->
    (if toggle => @add-class else @remove-class) node, cls
  find-class: (node, cls) ->
    !!node.getAttribute(\class).split(' ').filter(->it == cls).length

