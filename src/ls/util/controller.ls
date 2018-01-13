controller = do
  model-wrap: (node, data, dom) ->
    name = node.getAttribute('data-model')
    dom.model[name] = node
    data[name] = null
    switch node.nodeName.toLowerCase!
      | \input
        switch node.getAttribute("type")
          | \checkbox
            node.addEventListener \change, -> data[name] = @checked
          | otherwise
            node.addEventListener \input, -> data[name] = @value
      | \textarea
        node.addEventListener \input, -> data[name] = @value

  root-wrap: (cls, root, parent) ->
    [dom,data] = [{root, model: {}, text: {}},{}]
    nodes = root.querySelectorAll '*[data-dom]'
    for it in nodes => dom[it.getAttribute('data-dom')] = it
    nodes = root.querySelectorAll '*[data-model]'
    for it in nodes => @model-wrap it, data, dom
    nodes = root.querySelectorAll '*[data-text]'
    for it in nodes => dom.text[it.getAttribute('data-text')] = it
    node = new cls dom, data, parent
    node <<< {dom, data}

  register: (cls, parent) ->
    roots = document.querySelectorAll "*[data-controller=#{cls.controller}]"
    cls.prototype <<< do
      fire: (name, value) -> for cb in @{}_handlers[][name] => cb value
      listen: (name, cb) -> @{}_handlers[][name].push cb
      set-text: (name, value) -> @dom.text[name].innerText = value
      set: (name, value) ->
        @data[name] = value
        node = @dom.model[name]
        switch node.getAttribute("type")
          | \checkbox
            node.checked = !!value
          | otherwise
            node.value = value
        @fire name, value
      get: (name) -> return @data[name]
    return for root in roots => @root-wrap cls, root, parent
