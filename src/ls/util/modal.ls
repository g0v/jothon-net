modal = (dom, data) ->
  dom["mask"].addEventListener \click, ->
    dom.root.setAttribute \class, dom.root.getAttribute("class").replace(/ *active/g,"") + " inactive"

modal
  ..controller = 'modal'
