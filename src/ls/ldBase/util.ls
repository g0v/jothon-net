angular.module \ldBase
  ..filter \prettyColorHex, -> ->
    if !/rgba?/.exec(it) => return it
    ret = /rgba?\(([^,]+),([^,]+),([^,]+)(?:,([^,]+))?\)/.exec it
    hex = \# + [ret.1, ret.2, ret.3, ret.4]
      .map (d,i) ->
        if !d => return d
        v = +d
        if ~d.indexOf('%') => v = Math.round(+(d.replace('%','')) * 2.55).toString(16)
        else if +d < 1 => v = "#{Math.round(+d * 100) * 0.01}"
        if v.length < 2 => v = "0#v"
        if v.length > 4 => v = v.substring(0,4)
        if i == 3 => v = " / #v"
        v
      .join("")
    return hex
  ..filter \nicedate, -> ->
    date = new Date(it)
    "#{date.getYear! + 1900}/#{date.getMonth! + 1}/#{date.getDate!}"
  ..filter \nicedatetime, -> ->
    pad = (it) -> "#{if it < 10 => '0' else ''}#it"
    date = new Date(it)
    Y = date.getYear! + 1900
    M = pad(date.getMonth! + 1)
    D = pad date.getDate!
    h = pad date.getHours!
    m = pad date.getMinutes!
    s = pad date.getSeconds!
    "#Y/#M/#D #h:#m:#s"
  ..service \gautil, <[$rootScope]> ++ ($rootScope) ->
    do
      track: (cat, act, label, value) -> if ga? => ga \send, \event, cat, act, label, value
  ..service \initWrap, <[$rootScope]> ++ ($rootScope) ->
    _ = ->
      init = -> init[]list.push it; it <<< do
        promise: {}
        failed: (name='default', ...payload) ->
          if !@promise[name] => return
          rej = @promise[name].rej
          @promise[name] = null
          rej.apply null, payload
        finish: (name='default', ...payload) ->
          if !@promise[name] => return
          res = @promise[name].res
          @promise[name] = null
          res.apply null, payload
        block: (name='default')-> new Promise (res, rej) ~> @promise[name] = {res, rej}
      init <<< run: -> @[]list.map -> it.init!
  ..directive \ngModal, <[$compile $timeout]> ++ ($compile, $timeout) -> do
    restrict: \A
    scope: do
      model: \=ngModel
      config: \=config
    link: (s,e,a,c) -> 
      config = (s.config or {})
      s.model.ctrl = ctrl = do 
        promise: null
        focus: ->
          $timeout (->
            n = e.find("input[tabindex='1']")
            if n.length => n.focus!
          ), 0
        toggle: (t,v, a = \done) ->
          if v => @value = v
          if !t? or (!!@toggled != !!t) =>
            @toggled = if t? => t else !@toggled
            if @toggled => @focus!
            if !@toggled and ctrl.promise => s.model.action a
        # possible value for toggled: 
        #   null  - uninited ( for animation init state. )
        #   false - inactive
        #   true  - active
        toggled: null
        value: null
        reset: -> @value = ''
        init: ->
          @reset!
          e.on \keydown, (event) -> 
            key = event.keyCode or event.which
            if key != 13 => return
            tabindex = +event.target.getAttribute("tabindex") + 1
            n = e.find("input[tabindex='#{tabindex}']")
            if n and n.length => return n.0.focus!
            if config.dismissOnEnter => s.$apply -> s.model.action 'done'
            if config.finish? => config.finish!
      s.model.action = (a) -> # a could be 'done' or 'cancel'
        if a == 'done' => s.model.value = ctrl.value
        ctrl.toggle false, null, a
        if ctrl.promise =>
          if a == 'done' => ctrl.promise.res ctrl.value else ctrl.promise.rej a
          ctrl.promise = null
      s.model.prompt = (v) ->
        ctrl.toggle true, v
        new Promise (res, rej) ~> ctrl.promise = {res, rej}
      s.model.ctrl.init!

  ..directive \ngIonSlider, <[$compile]> ++ ($compile) -> do
    restrict: \A
    scope: do
      model: \=ngValue
      config: \=config
      switch: \=ngSwitch
      # s.switch => false = input, true = slider.
      # a.defaultSwitch => if s.switch is undefined or not given, use a.defaultSwitch as default
    link: (s,e,a,c) ->
      e.0.addEventListener \keyup, -> if e.0.value != s.model => s.$apply -> s.model = e.0.value or 0
      e.0.addEventListener \change, -> if e.0.value != s.model => s.$apply -> s.model = e.0.value or 0
      if a.ngSwitch? and !s.switch? => s.switch = if a.defaultSwitch? => a.defaultSwitch == true else true
      s.$watch 'model', -> e.0.value = it or 0
      inited = false
      s.$watch 'switch', (n,o) ->
        if !a.ngSwitch => n = if a.defaultSwitch? => a.defaultSwitch == \true else true
        if n and !inited =>
          inited := true
          config = s.config or {}
          isDouble = config.type == \double
          if isDouble and !Array.isArray(s.model) => s.model = [0,100]
          s.$watch 'config', (config) -> slider.update(config)
          s.$watch 'model', ->
            if isDouble =>
              if slider.result.from != it.0 => slider.update({from: it.0})
              if slider.result.to != it.1 => slider.update({to: it.1})
            else
              if slider.result.from != +it => slider.update({from: it})
            e.removeAttr \readonly
          $(e).ionRangeSlider {} <<< config <<< do
            onChange: (v) -> s.$apply ->
              if isDouble =>
                if s.model.0  != v.from => s.model.0 = v.from
                if s.model.1  != v.to => s.model.1 = v.to
              else if s.model != v.from => s.model = v.from
          slider = $(e).data \ionRangeSlider
        if !n =>
          e.removeClass \irs-hidden-input
          e.removeAttr \readonly
          e.parent!addClass \input
        else
          e.addClass \irs-hidden-input
          e.attr \readonly, true
          e.parent!removeClass \input

  ..directive \readby, <[$compile]> ++ ($compile) ->
    do
      scope: do
        readby: \&readby
        encoding: \@encoding
        askencoding: \&askencoding
        multiple: \@multiple
      link: (s,e,a,c) ->
        handler = s.readby!
        askencoding = s.askencoding!
        e.bind \change, (event) ->
          reader = ->
            files = event.target.files
            if !files.length => return
            if a.multiple =>
              loadfile = (f) -> new Promise (res, rej) ->
                fr = new FileReader!
                fr.onload = ->
                  res {result: fr.result, file: f}
                if a.asdataurl => fr.readAsDataURL f
                else if s.encoding => fr.readAsText f, s.encoding
                else fr.readAsBinaryString f
              promises = Array.from(files).map -> loadfile it
              Promise.all promises .then (ret) ->
                s.$apply -> handler ret
                e.val("")
            else =>
              fr = new FileReader!
              fr.onload = ->
                s.$apply -> handler fr.result, files.0
                e.val("")
              if a.asdataurl? => fr.readAsDataURL files.0
              else if a.asarraybuffer? => fr.readAsArrayBuffer files.0
              else if s.encoding => fr.readAsText files.0, s.encoding
              else fr.readAsBinaryString files.0

          s.$apply ->
            if askencoding => askencoding reader
            else reader!
  ..directive \ngGradient, <[$compile]> ++ ($compile) -> do
    restrict: \A
    scope: do
      model: \=ngValue
      config: \=config
    link: (s,e,a,c) ->
      s.idx = null
      cp = e.0.querySelector \.ldColorPicker
      #ldcp = new ldColorPicker null, {class: 'text-input no-palette flat'}, cp
      ldcp = new ldColorPicker null, {class: 'text-input no-palette flat'}
      cp = ldcp.node
      cp.style.display = \none
      is-move = false
      is-tick = false
      is-break = true
      make-gradient = ->
        if !s.model => return
        s.gradient = [
          "linear-gradient(90deg,"
          s.model.colors.map(-> "#{it.value} #{it.pos * 100}%").join(",")
          ")"
        ].join("")
        e.0.querySelector(".gradient-inner").style.background = s.gradient
      s.$watch 'model', -> make-gradient!
      ldcp.on \change, (c) -> s.$apply -> if s.idx? and s.model =>
        s.model.colors[s.idx].value = c
        make-gradient!
      e.0.addEventListener \mouseup, (evt) -> s.$apply ->
        is-break := true
        if !is-tick or is-move or !s.idx? => return
        tick = evt.target.getBoundingClientRect!
        node = e.0.getBoundingClientRect!
        if s.lastidx != s.idx or cp.style.display != \block =>
          setTimeout (->ldcp.toggle that ), 0
        cp.style.top = "#{tick.bottom + 15 + document.body.scrollTop}px"
        cp.style.left = "#{tick.left - 15 + document.body.scrollLeft}px"
        evt.stopPropagation!; evt.preventDefault!
      e.0.addEventListener \click, (evt) -> s.$apply ->
        if is-move or (evt.target != e.0 and evt.target != e.0.querySelector(".gradient-inner")) => return
        rect = e.0.getBoundingClientRect!
        left = ((evt.clientX - rect.left)/(rect.width))
        left <?= 1
        left >?= 0
        if s.model =>
          s.model.colors.push {value: '#000000', pos: left}
          s.model.colors.sort (a,b) -> a.pos - b.pos
          make-gradient!
          ldcp.toggle false
      window.addEventListener \mousedown, (evt) -> s.$apply ->
        is-move := false
        is-tick := false
        if evt.target.parentNode != e.0 => return
        is-break := false
        s.lastidx = s.idx
        s.idx = Array.from(evt.target.parentNode.childNodes)
          .filter(->it.getAttribute and /tick/.exec(it.getAttribute("class")))
          .indexOf(evt.target)
        if s.idx < 0 => return s.idx = null
        is-tick := true
        evt.preventDefault!
        evt.stopPropagation!
      window.addEventListener \mousemove, (evt) -> s.$apply ->
        is-move := true
        rect = e.0.getBoundingClientRect!
        left = ((evt.clientX - rect.left)/(rect.width))
        left <?= 1
        left >?= 0
        yOffset = Math.abs(evt.clientY - (rect.top + rect.height/2))
        btn = evt.buttons or evt.button
        if !is-break and btn and s.idx? =>
          ldcp.toggle false
          if yOffset > rect.height/2 + 60 =>
            if s.model => s.model.colors.splice s.idx, 1
            s.idx = null
            make-gradient!
          else if s.model
            if s.idx > 0 => if s.model.colors[s.idx - 1].pos > left => left = s.model.colors[s.idx - 1].pos
            if s.idx < s.model.colors.length - 1 =>
              if s.model.colors[s.idx + 1].pos < left => left = s.model.colors[s.idx + 1].pos
            s.model.colors[s.idx].pos = left
            make-gradient!
      make-gradient!
  ..directive \ngClipboard, <[$compile]> ++ ($compile) -> do
    restrict: \A
    scope: {}
    link: (s,e,a,c) ->
      clipboard = new Clipboard e.0, {target: -> document.querySelector(a.target)}
      tip = document.createElement \div
      tip.setAttribute \class, "hover-tip #{a.dir or 'top'}"
      e.0.appendChild tip
      clipboard.on \success, ->
        e.addClass \copied
        tip.innerText = 'copied'
        setTimeout((-> e.removeClass \copied), 1000)
      clipboard.on \error, ->
        e.addClass \copied
        tip.innerText = 'Press Ctrl+C to Copy'
        setTimeout((->e.removeClass \copied), 1000)
  ..directive \ngDrop, <[$compile]> ++ ($compile) -> do
    restrict: \A
    scope: do
      swap: \&swap
    link: (s,e,a,c) ->
      if a.swap => handler = s.swap!
      find-block = (node) ->
        if node.getAttribute(\draggable) => return node
        else return node.parentNode
      e.0.addEventListener \dragenter, (evt) -> evt.preventDefault!
      e.0.addEventListener \dragover, (evt) ->
        evt.preventDefault!
        evt.dataTransfer.dropEffect = \move
      e.0.addEventListener \dragstart, (evt) ->
        target = find-block evt.target
        idx = Array.from(target.parentNode.querySelectorAll('*[draggable=true]')).indexOf(target)
        evt.dataTransfer.setData \text/plain, idx
      e.0.addEventListener \drop, (evt) ->
        target = find-block evt.target
        src = +evt.dataTransfer.getData(\text)
        des = Array.from(target.parentNode.querySelectorAll('*[draggable=true]')).indexOf(target)
        if src >= 0 and des >= 0 and handler => handler src, des

  ..directive \ngPaypal, <[$compile global $timeout gautil]> ++ ($compile, global, $timeout, gautil) -> do
    restrict: \A
    scope: do
      model: \=ngModel
      trackid: \@trackid
      type: \@type
      id: \@itemid
      price: \@price
      format: \@format
    link: (s,e,a,c) ->
      container = document.createElement("div")
      container.id = "paypal-btn-#{Math.random!toString!substring 2}"
      container.setAttribute \class, "paypal-btn-inner"
      loader = document.createElement("div")
      loader.id = "paypal-btn-#{Math.random!toString!substring 2}-loader"
      loader.setAttribute \class, "ld ld-ball ld-flip"
      e.0.appendChild container
      e.0.appendChild loader
      e.addClass "ld ld-over-inverse running"
      s.paid = false
      s.$watch 'model.list', ((n,o) ->
        if n == o or !n or !n.length => return
        len = n.filter(-> it.type == s.type and it.item == s.id ).length
        if len => e.addClass \paid else e.removeClass \paid
        s.paid = if len => true else false
      ), true
      e.on \click, -> if s.paid => s.model.paid s{trackid, id, type, price, format}
      ctrl = do
        init: ->
          if @inited => return
          if !paypal? => return $timeout (-> ctrl.init! ), 1000
          @inited = true
          paypal.Button.render({
            env: if global.production => \production else \sandbox
            style: size: \responsive
            payment: (res, rej) ->
              gautil.track s.trackid, "pay-button", \click
              paypal.request.post(
                \/d/create-payment/,
                {type: s.type, id: s.id},
                headers: {"X-CSRF-Token": global.csrfToken}
              )
               .then (data) -> res data.paymentID
               .catch (err) -> rej err
            onAuthorize: (data) ->
              paypal.request.post(
                \/d/execute-payment/
                data{paymentID, payerID} <<< {type: s.type, id: s.id}
                {headers: "X-CSRF-Token": global.csrfToken}
              )
                .then (data) ->
                  s.$apply -> if s.model.paid? => s.model.paid s{trackid, id, type, price, format}
                  gautil.track s.trackid, "paid", (s.format or ''), 1.99
                  return null
                .catch (err) ->
                  console.log err
                  alert "Something wrong in the payment process. please try again."
          }, container.id)
            .then -> e.removeClass \running
      ctrl.init!
