angular.module \ldBase, <[]>
  ..service 'eventBus', <[$rootScope]> ++ ($rootScope) ->
    ret = @ <<< do
      queues: {}
      handlers: {}
      process: (name=null) ->
        if !name => list = [[k,v] for k,v of @queues]
        else list = [[name, @queues[][name]]]
        ([k,v]) <~ list.map
        if !v or !v.length => return
        for func in (@handlers[k] or []) => for payload in v => func.apply null, [payload.0] ++ payload.1
        @queues[][name].splice 0, @queues[][name].length
      listen: (name, cb) ->
        @handlers[][name].push cb
        @process name
      fire: (name, payload, ...params) ->
        @queues[][name].push [payload, params]
        @process name

  ..service 'ldNotify', <[$rootScope $timeout]> ++ ($rootScope, $timeout) -> @ <<< do
    queue: []
    send: (type, message) -> 
      @queue.push node = {type, message}
      $timeout (~> @queue.splice @queue.indexOf(node), 1), 5000
    danger: (message) -> @send \danger, message
    warning: (message) -> @send \warning, message
    info: (message) -> @send \info, message
    success: (message) -> @send \success, message

  ..service 'ldBase', <[$rootScope $timeout ldNotify]> ++ ($rootScope, $timeout, ldNotify) ->
    easeInOutQuad = (t,b,c,d) ->
      t = t / (d * 0.5)
      if t < 1 => return c * 0.5 * t * t + b
      t = t - 1
      return -c * 0.5 * ( t * (t - 2) - 1 ) + b
    @ <<< do
      track: (cat, act, label, value) -> if ga? => ga \send, \event, cat, act, label, value
      notifications: ldNotify.queue
      scrollto: (node, dur = 500) ->
        element = document.documentElement or document.body
        if typeof(node) == \string => node = document.querySelector node
        [des, src]= [node.getBoundingClientRect!top, window.pageYOffset]
        [diff,start] = [des - src, -1]
        animateScroll = (timestamp) ->
          if start < 0 => start := timestamp
          val = easeInOutQuad timestamp - start, src, diff, dur
          element.scrollTop = val
          if timestamp <= start + dur => requestAnimationFrame animateScroll
        requestAnimationFrame animateScroll
