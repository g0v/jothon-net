controller = do
  model-wrap: (node, data, dom) ->
    name = node.getAttribute('data-model')
    dom.model[name] = node
    data[name] = null
    if node.nodeName.toLowerCase! == \input =>
      switch node.getAttribute("type")
        | \checkbox
          node.addEventListener \change, -> data[name] = @checked
        | otherwise
          node.addEventListener \input, -> data[name] = @value

  root-wrap: (cls, root) ->
    [dom,data] = [{root, model: {}, text: {}},{}]
    nodes = root.querySelectorAll '*[data-dom]'
    for it in nodes => dom[it.getAttribute('data-dom')] = it
    nodes = root.querySelectorAll '*[data-model]'
    for it in nodes => @model-wrap it, data, dom
    nodes = root.querySelectorAll '*[data-text]'
    for it in nodes => dom.text[it.getAttribute('data-text')] = it
    node = new cls dom, data

  register: (cls) ->
    roots = document.querySelectorAll "*[data-controller=#{cls.controller}]"
    cls.prototype <<< do
      listen: (name, cb) -> @_handlers[][name].push cb
      set-text: (name, value) -> @dom.text[name].innerText = value
      set: (name, value) ->
        @data[name] = value
        node = @dom.model[name]
        switch node.getAttribute("type")
          | \checkbox
            node.checked = !!value
          | otherwise
            node.value = value
        for cb in @_handlers[][name] => cb value
      get: (name) -> return @data[name]
    for root in roots => @root-wrap cls, root
