var x$;
x$ = angular.module('ldBase');
x$.filter('prettyColorHex', function(){
  return function(it){
    var ret, hex;
    if (!/rgba?/.exec(it)) {
      return it;
    }
    ret = /rgba?\(([^,]+),([^,]+),([^,]+)(?:,([^,]+))?\)/.exec(it);
    hex = '#' + [ret[1], ret[2], ret[3], ret[4]].map(function(d, i){
      var v;
      if (!d) {
        return d;
      }
      v = +d;
      if (~d.indexOf('%')) {
        v = Math.round(+d.replace('%', '') * 2.55).toString(16);
      } else if (+d < 1) {
        v = Math.round(+d * 100) * 0.01 + "";
      }
      if (v.length < 2) {
        v = "0" + v;
      }
      if (v.length > 4) {
        v = v.substring(0, 4);
      }
      if (i === 3) {
        v = " / " + v;
      }
      return v;
    }).join("");
    return hex;
  };
});
x$.filter('nicedate', function(){
  return function(it){
    var date;
    date = new Date(it);
    return (date.getYear() + 1900) + "/" + (date.getMonth() + 1) + "/" + date.getDate();
  };
});
x$.filter('nicedatetime', function(){
  return function(it){
    var pad, date, Y, M, D, h, m, s;
    pad = function(it){
      return (it < 10 ? '0' : '') + "" + it;
    };
    date = new Date(it);
    Y = date.getYear() + 1900;
    M = pad(date.getMonth() + 1);
    D = pad(date.getDate());
    h = pad(date.getHours());
    m = pad(date.getMinutes());
    s = pad(date.getSeconds());
    return Y + "/" + M + "/" + D + " " + h + ":" + m + ":" + s;
  };
});
x$.service('gautil', ['$rootScope'].concat(function($rootScope){
  return {
    track: function(cat, act, label, value){
      if (typeof ga != 'undefined' && ga !== null) {
        return ga('send', 'event', cat, act, label, value);
      }
    }
  };
}));
x$.service('initWrap', ['$rootScope'].concat(function($rootScope){
  var _;
  return _ = function(){
    var init;
    init = function(it){
      (init.list || (init.list = [])).push(it);
      return import$(it, {
        promise: {},
        failed: function(name){
          var payload, res$, i$, to$, rej;
          name == null && (name = 'default');
          res$ = [];
          for (i$ = 1, to$ = arguments.length; i$ < to$; ++i$) {
            res$.push(arguments[i$]);
          }
          payload = res$;
          if (!this.promise[name]) {
            return;
          }
          rej = this.promise[name].rej;
          this.promise[name] = null;
          return rej.apply(null, payload);
        },
        finish: function(name){
          var payload, res$, i$, to$, res;
          name == null && (name = 'default');
          res$ = [];
          for (i$ = 1, to$ = arguments.length; i$ < to$; ++i$) {
            res$.push(arguments[i$]);
          }
          payload = res$;
          if (!this.promise[name]) {
            return;
          }
          res = this.promise[name].res;
          this.promise[name] = null;
          return res.apply(null, payload);
        },
        block: function(name){
          var this$ = this;
          name == null && (name = 'default');
          return new Promise(function(res, rej){
            return this$.promise[name] = {
              res: res,
              rej: rej
            };
          });
        }
      });
    };
    return init.run = function(){
      return (this.list || (this.list = [])).map(function(it){
        return it.init();
      });
    }, init;
  };
}));
x$.directive('ngModal', ['$compile', '$timeout'].concat(function($compile, $timeout){
  return {
    restrict: 'A',
    scope: {
      model: '=ngModel',
      config: '=config'
    },
    link: function(s, e, a, c){
      var config, ctrl;
      config = s.config || {};
      s.model.ctrl = ctrl = {
        promise: null,
        focus: function(){
          return $timeout(function(){
            var n;
            n = e.find("input[tabindex='1']");
            if (n.length) {
              return n.focus();
            }
          }, 0);
        },
        toggle: function(t, v, a){
          a == null && (a = 'done');
          if (v) {
            this.value = v;
          }
          if (t == null || !!this.toggled !== !!t) {
            this.toggled = t != null
              ? t
              : !this.toggled;
            if (this.toggled) {
              this.focus();
            }
            if (!this.toggled && ctrl.promise) {
              return s.model.action(a);
            }
          }
        },
        toggled: null,
        value: null,
        reset: function(){
          return this.value = '';
        },
        init: function(){
          this.reset();
          return e.on('keydown', function(event){
            var key, tabindex, n;
            key = event.keyCode || event.which;
            if (key !== 13) {
              return;
            }
            tabindex = +event.target.getAttribute("tabindex") + 1;
            n = e.find("input[tabindex='" + tabindex + "']");
            if (n && n.length) {
              return n[0].focus();
            }
            if (config.dismissOnEnter) {
              s.$apply(function(){
                return s.model.action('done');
              });
            }
            if (config.finish != null) {
              return config.finish();
            }
          });
        }
      };
      s.model.action = function(a){
        if (a === 'done') {
          s.model.value = ctrl.value;
        }
        ctrl.toggle(false, null, a);
        if (ctrl.promise) {
          if (a === 'done') {
            ctrl.promise.res(ctrl.value);
          } else {
            ctrl.promise.rej(a);
          }
          return ctrl.promise = null;
        }
      };
      s.model.prompt = function(v){
        ctrl.toggle(true, v);
        return new Promise(function(res, rej){
          return ctrl.promise = {
            res: res,
            rej: rej
          };
        });
      };
      return s.model.ctrl.init();
    }
  };
}));
x$.directive('ngIonSlider', ['$compile'].concat(function($compile){
  return {
    restrict: 'A',
    scope: {
      model: '=ngValue',
      config: '=config',
      'switch': '=ngSwitch'
    },
    link: function(s, e, a, c){
      var inited;
      e[0].addEventListener('keyup', function(){
        if (e[0].value !== s.model) {
          return s.$apply(function(){
            return s.model = e[0].value || 0;
          });
        }
      });
      e[0].addEventListener('change', function(){
        if (e[0].value !== s.model) {
          return s.$apply(function(){
            return s.model = e[0].value || 0;
          });
        }
      });
      if (a.ngSwitch != null && s['switch'] == null) {
        s['switch'] = a.defaultSwitch != null ? a.defaultSwitch === true : true;
      }
      s.$watch('model', function(it){
        return e[0].value = it || 0;
      });
      inited = false;
      return s.$watch('switch', function(n, o){
        var config, isDouble, slider;
        if (!a.ngSwitch) {
          n = a.defaultSwitch != null ? a.defaultSwitch === 'true' : true;
        }
        if (n && !inited) {
          inited = true;
          config = s.config || {};
          isDouble = config.type === 'double';
          if (isDouble && !Array.isArray(s.model)) {
            s.model = [0, 100];
          }
          s.$watch('config', function(config){
            return slider.update(config);
          });
          s.$watch('model', function(it){
            if (isDouble) {
              if (slider.result.from !== it[0]) {
                slider.update({
                  from: it[0]
                });
              }
              if (slider.result.to !== it[1]) {
                slider.update({
                  to: it[1]
                });
              }
            } else {
              if (slider.result.from !== +it) {
                slider.update({
                  from: it
                });
              }
            }
            return e.removeAttr('readonly');
          });
          $(e).ionRangeSlider(import$(import$({}, config), {
            onChange: function(v){
              return s.$apply(function(){
                if (isDouble) {
                  if (s.model[0] !== v.from) {
                    s.model[0] = v.from;
                  }
                  if (s.model[1] !== v.to) {
                    return s.model[1] = v.to;
                  }
                } else if (s.model !== v.from) {
                  return s.model = v.from;
                }
              });
            }
          }));
          slider = $(e).data('ionRangeSlider');
        }
        if (!n) {
          e.removeClass('irs-hidden-input');
          e.removeAttr('readonly');
          return e.parent().addClass('input');
        } else {
          e.addClass('irs-hidden-input');
          e.attr('readonly', true);
          return e.parent().removeClass('input');
        }
      });
    }
  };
}));
x$.directive('readby', ['$compile'].concat(function($compile){
  return {
    scope: {
      readby: '&readby',
      encoding: '@encoding',
      askencoding: '&askencoding',
      multiple: '@multiple'
    },
    link: function(s, e, a, c){
      var handler, askencoding;
      handler = s.readby();
      askencoding = s.askencoding();
      return e.bind('change', function(event){
        var reader;
        reader = function(){
          var files, loadfile, promises, fr;
          files = event.target.files;
          if (!files.length) {
            return;
          }
          if (a.multiple) {
            loadfile = function(f){
              return new Promise(function(res, rej){
                var fr;
                fr = new FileReader();
                fr.onload = function(){
                  return res({
                    result: fr.result,
                    file: f
                  });
                };
                if (a.asdataurl) {
                  return fr.readAsDataURL(f);
                } else if (s.encoding) {
                  return fr.readAsText(f, s.encoding);
                } else {
                  return fr.readAsBinaryString(f);
                }
              });
            };
            promises = Array.from(files).map(function(it){
              return loadfile(it);
            });
            return Promise.all(promises).then(function(ret){
              s.$apply(function(){
                return handler(ret);
              });
              return e.val("");
            });
          } else {
            fr = new FileReader();
            fr.onload = function(){
              s.$apply(function(){
                return handler(fr.result, files[0]);
              });
              return e.val("");
            };
            if (a.asdataurl != null) {
              return fr.readAsDataURL(files[0]);
            } else if (a.asarraybuffer != null) {
              return fr.readAsArrayBuffer(files[0]);
            } else if (s.encoding) {
              return fr.readAsText(files[0], s.encoding);
            } else {
              return fr.readAsBinaryString(files[0]);
            }
          }
        };
        return s.$apply(function(){
          if (askencoding) {
            return askencoding(reader);
          } else {
            return reader();
          }
        });
      });
    }
  };
}));
x$.directive('ngGradient', ['$compile'].concat(function($compile){
  return {
    restrict: 'A',
    scope: {
      model: '=ngValue',
      config: '=config'
    },
    link: function(s, e, a, c){
      var cp, ldcp, isMove, isTick, isBreak, makeGradient;
      s.idx = null;
      cp = e[0].querySelector('.ldColorPicker');
      ldcp = new ldColorPicker(null, {
        'class': 'text-input no-palette flat'
      });
      cp = ldcp.node;
      cp.style.display = 'none';
      isMove = false;
      isTick = false;
      isBreak = true;
      makeGradient = function(){
        if (!s.model) {
          return;
        }
        s.gradient = [
          "linear-gradient(90deg,", s.model.colors.map(function(it){
            return it.value + " " + it.pos * 100 + "%";
          }).join(","), ")"
        ].join("");
        return e[0].querySelector(".gradient-inner").style.background = s.gradient;
      };
      s.$watch('model', function(){
        return makeGradient();
      });
      ldcp.on('change', function(c){
        return s.$apply(function(){
          if (s.idx != null && s.model) {
            s.model.colors[s.idx].value = c;
            return makeGradient();
          }
        });
      });
      e[0].addEventListener('mouseup', function(evt){
        return s.$apply(function(){
          var tick, node, that;
          isBreak = true;
          if (!isTick || isMove || s.idx == null) {
            return;
          }
          tick = evt.target.getBoundingClientRect();
          node = e[0].getBoundingClientRect();
          if (that = s.lastidx !== s.idx || cp.style.display !== 'block') {
            setTimeout(function(){
              return ldcp.toggle(that);
            }, 0);
          }
          cp.style.top = (tick.bottom + 15 + document.body.scrollTop) + "px";
          cp.style.left = (tick.left - 15 + document.body.scrollLeft) + "px";
          evt.stopPropagation();
          return evt.preventDefault();
        });
      });
      e[0].addEventListener('click', function(evt){
        return s.$apply(function(){
          var rect, left;
          if (isMove || (evt.target !== e[0] && evt.target !== e[0].querySelector(".gradient-inner"))) {
            return;
          }
          rect = e[0].getBoundingClientRect();
          left = (evt.clientX - rect.left) / rect.width;
          left <= 1 || (left = 1);
          left >= 0 || (left = 0);
          if (s.model) {
            s.model.colors.push({
              value: '#000000',
              pos: left
            });
            s.model.colors.sort(function(a, b){
              return a.pos - b.pos;
            });
            makeGradient();
            return ldcp.toggle(false);
          }
        });
      });
      window.addEventListener('mousedown', function(evt){
        return s.$apply(function(){
          isMove = false;
          isTick = false;
          if (evt.target.parentNode !== e[0]) {
            return;
          }
          isBreak = false;
          s.lastidx = s.idx;
          s.idx = Array.from(evt.target.parentNode.childNodes).filter(function(it){
            return it.getAttribute && /tick/.exec(it.getAttribute("class"));
          }).indexOf(evt.target);
          if (s.idx < 0) {
            return s.idx = null;
          }
          isTick = true;
          evt.preventDefault();
          return evt.stopPropagation();
        });
      });
      window.addEventListener('mousemove', function(evt){
        return s.$apply(function(){
          var rect, left, yOffset, btn;
          isMove = true;
          rect = e[0].getBoundingClientRect();
          left = (evt.clientX - rect.left) / rect.width;
          left <= 1 || (left = 1);
          left >= 0 || (left = 0);
          yOffset = Math.abs(evt.clientY - (rect.top + rect.height / 2));
          btn = evt.buttons || evt.button;
          if (!isBreak && btn && s.idx != null) {
            ldcp.toggle(false);
            if (yOffset > rect.height / 2 + 60) {
              if (s.model) {
                s.model.colors.splice(s.idx, 1);
              }
              s.idx = null;
              return makeGradient();
            } else if (s.model) {
              if (s.idx > 0) {
                if (s.model.colors[s.idx - 1].pos > left) {
                  left = s.model.colors[s.idx - 1].pos;
                }
              }
              if (s.idx < s.model.colors.length - 1) {
                if (s.model.colors[s.idx + 1].pos < left) {
                  left = s.model.colors[s.idx + 1].pos;
                }
              }
              s.model.colors[s.idx].pos = left;
              return makeGradient();
            }
          }
        });
      });
      return makeGradient();
    }
  };
}));
x$.directive('ngClipboard', ['$compile'].concat(function($compile){
  return {
    restrict: 'A',
    scope: {},
    link: function(s, e, a, c){
      var clipboard, tip;
      clipboard = new Clipboard(e[0], {
        target: function(){
          return document.querySelector(a.target);
        }
      });
      tip = document.createElement('div');
      tip.setAttribute('class', "hover-tip " + (a.dir || 'top'));
      e[0].appendChild(tip);
      clipboard.on('success', function(){
        e.addClass('copied');
        tip.innerText = 'copied';
        return setTimeout(function(){
          return e.removeClass('copied');
        }, 1000);
      });
      return clipboard.on('error', function(){
        e.addClass('copied');
        tip.innerText = 'Press Ctrl+C to Copy';
        return setTimeout(function(){
          return e.removeClass('copied');
        }, 1000);
      });
    }
  };
}));
x$.directive('ngDrop', ['$compile'].concat(function($compile){
  return {
    restrict: 'A',
    scope: {
      swap: '&swap'
    },
    link: function(s, e, a, c){
      var handler, findBlock;
      if (a.swap) {
        handler = s.swap();
      }
      findBlock = function(node){
        if (node.getAttribute('draggable')) {
          return node;
        } else {
          return node.parentNode;
        }
      };
      e[0].addEventListener('dragenter', function(evt){
        return evt.preventDefault();
      });
      e[0].addEventListener('dragover', function(evt){
        evt.preventDefault();
        return evt.dataTransfer.dropEffect = 'move';
      });
      e[0].addEventListener('dragstart', function(evt){
        var target, idx;
        target = findBlock(evt.target);
        idx = Array.from(target.parentNode.querySelectorAll('*[draggable=true]')).indexOf(target);
        return evt.dataTransfer.setData('text/plain', idx);
      });
      return e[0].addEventListener('drop', function(evt){
        var target, src, des;
        target = findBlock(evt.target);
        src = +evt.dataTransfer.getData('text');
        des = Array.from(target.parentNode.querySelectorAll('*[draggable=true]')).indexOf(target);
        if (src >= 0 && des >= 0 && handler) {
          return handler(src, des);
        }
      });
    }
  };
}));
x$.directive('ngPaypal', ['$compile', 'global', '$timeout', 'gautil'].concat(function($compile, global, $timeout, gautil){
  return {
    restrict: 'A',
    scope: {
      model: '=ngModel',
      trackid: '@trackid',
      type: '@type',
      id: '@itemid',
      price: '@price',
      format: '@format'
    },
    link: function(s, e, a, c){
      var container, loader, ctrl;
      container = document.createElement("div");
      container.id = "paypal-btn-" + Math.random().toString().substring(2);
      container.setAttribute('class', "paypal-btn-inner");
      loader = document.createElement("div");
      loader.id = "paypal-btn-" + Math.random().toString().substring(2) + "-loader";
      loader.setAttribute('class', "ld ld-ball ld-flip");
      e[0].appendChild(container);
      e[0].appendChild(loader);
      e.addClass("ld ld-over-inverse running");
      s.paid = false;
      s.$watch('model.list', function(n, o){
        var len;
        if (n === o || !n || !n.length) {
          return;
        }
        len = n.filter(function(it){
          return it.type === s.type && it.item === s.id;
        }).length;
        if (len) {
          e.addClass('paid');
        } else {
          e.removeClass('paid');
        }
        return s.paid = len ? true : false;
      }, true);
      e.on('click', function(){
        if (s.paid) {
          return s.model.paid({
            trackid: s.trackid,
            id: s.id,
            type: s.type,
            price: s.price,
            format: s.format
          });
        }
      });
      ctrl = {
        init: function(){
          if (this.inited) {
            return;
          }
          if (typeof paypal == 'undefined' || paypal === null) {
            return $timeout(function(){
              return ctrl.init();
            }, 1000);
          }
          this.inited = true;
          return paypal.Button.render({
            env: global.production ? 'production' : 'sandbox',
            style: {
              size: 'responsive'
            },
            payment: function(res, rej){
              gautil.track(s.trackid, "pay-button", 'click');
              return paypal.request.post('/d/create-payment/', {
                type: s.type,
                id: s.id
              }, {
                headers: {
                  "X-CSRF-Token": global.csrfToken
                }
              }).then(function(data){
                return res(data.paymentID);
              })['catch'](function(err){
                return rej(err);
              });
            },
            onAuthorize: function(data){
              var ref$;
              return paypal.request.post('/d/execute-payment/', (ref$ = {
                paymentID: data.paymentID,
                payerID: data.payerID
              }, ref$.type = s.type, ref$.id = s.id, ref$), {
                headers: {
                  "X-CSRF-Token": global.csrfToken
                }
              }).then(function(data){
                s.$apply(function(){
                  if (s.model.paid != null) {
                    return s.model.paid({
                      trackid: s.trackid,
                      id: s.id,
                      type: s.type,
                      price: s.price,
                      format: s.format
                    });
                  }
                });
                gautil.track(s.trackid, "paid", s.format || '', 1.99);
                return null;
              })['catch'](function(err){
                console.log(err);
                return alert("Something wrong in the payment process. please try again.");
              });
            }
          }, container.id).then(function(){
            return e.removeClass('running');
          });
        }
      };
      return ctrl.init();
    }
  };
}));
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}