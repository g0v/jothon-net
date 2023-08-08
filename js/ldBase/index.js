var x$;
x$ = angular.module('ldBase', []);
x$.service('eventBus', ['$rootScope'].concat(function($rootScope){
  var ret;
  return ret = import$(this, {
    queues: {},
    handlers: {},
    process: function(name){
      var list, res$, k, ref$, v, this$ = this;
      name == null && (name = null);
      if (!name) {
        res$ = [];
        for (k in ref$ = this.queues) {
          v = ref$[k];
          res$.push([k, v]);
        }
        list = res$;
      } else {
        list = [[name, (ref$ = this.queues)[name] || (ref$[name] = [])]];
      }
      return list.map(function(arg$){
        var k, v, i$, ref$, len$, func, j$, len1$, payload;
        k = arg$[0], v = arg$[1];
        if (!v || !v.length) {
          return;
        }
        for (i$ = 0, len$ = (ref$ = this$.handlers[k] || []).length; i$ < len$; ++i$) {
          func = ref$[i$];
          for (j$ = 0, len1$ = v.length; j$ < len1$; ++j$) {
            payload = v[j$];
            func.apply(null, [payload[0]].concat(payload[1]));
          }
        }
        return ((ref$ = this$.queues)[name] || (ref$[name] = [])).splice(0, ((ref$ = this$.queues)[name] || (ref$[name] = [])).length);
      });
    },
    listen: function(name, cb){
      var ref$;
      ((ref$ = this.handlers)[name] || (ref$[name] = [])).push(cb);
      return this.process(name);
    },
    fire: function(name, payload){
      var params, res$, i$, to$, ref$;
      res$ = [];
      for (i$ = 2, to$ = arguments.length; i$ < to$; ++i$) {
        res$.push(arguments[i$]);
      }
      params = res$;
      ((ref$ = this.queues)[name] || (ref$[name] = [])).push([payload, params]);
      return this.process(name);
    }
  });
}));
x$.service('ldNotify', ['$rootScope', '$timeout'].concat(function($rootScope, $timeout){
  return import$(this, {
    queue: [],
    send: function(type, message){
      var node, this$ = this;
      this.queue.push(node = {
        type: type,
        message: message
      });
      return $timeout(function(){
        return this$.queue.splice(this$.queue.indexOf(node), 1);
      }, 5000);
    },
    danger: function(message){
      return this.send('danger', message);
    },
    warning: function(message){
      return this.send('warning', message);
    },
    info: function(message){
      return this.send('info', message);
    },
    success: function(message){
      return this.send('success', message);
    }
  });
}));
x$.service('ldBase', ['$rootScope', '$timeout', 'ldNotify'].concat(function($rootScope, $timeout, ldNotify){
  var easeInOutQuad;
  easeInOutQuad = function(t, b, c, d){
    t = t / (d * 0.5);
    if (t < 1) {
      return c * 0.5 * t * t + b;
    }
    t = t - 1;
    return -c * 0.5 * (t * (t - 2) - 1) + b;
  };
  return import$(this, {
    track: function(cat, act, label, value){
      if (typeof ga != 'undefined' && ga !== null) {
        return ga('send', 'event', cat, act, label, value);
      }
    },
    notifications: ldNotify.queue,
    scrollto: function(node, dur){
      var element, ref$, des, src, diff, start, animateScroll;
      dur == null && (dur = 500);
      element = document.documentElement || document.body;
      if (typeof node === 'string') {
        node = document.querySelector(node);
      }
      ref$ = [node.getBoundingClientRect().top, window.pageYOffset], des = ref$[0], src = ref$[1];
      ref$ = [des - src, -1], diff = ref$[0], start = ref$[1];
      animateScroll = function(timestamp){
        var val;
        if (start < 0) {
          start = timestamp;
        }
        val = easeInOutQuad(timestamp - start, src, diff, dur);
        element.scrollTop = val;
        if (timestamp <= start + dur) {
          return requestAnimationFrame(animateScroll);
        }
      };
      return requestAnimationFrame(animateScroll);
    }
  });
}));
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}