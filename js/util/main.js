$(document).ready(function(){
  var main, navbar, authpanel, consentpage, profilePage;
  if (typeof csrfToken != 'undefined' && csrfToken !== null) {
    $.ajaxSetup({
      headers: {
        "X-CSRF-Token": csrfToken
      }
    });
  }
  main = {
    monitorList: {},
    monitor: function(name, cb){
      var ref$;
      return ((ref$ = this.monitorList)[name] || (ref$[name] = [])).push(cb);
    },
    broadcast: function(name, value){
      var i$, ref$, len$, func, results$ = [];
      for (i$ = 0, len$ = (ref$ = this.monitorList[name]).length; i$ < len$; ++i$) {
        func = ref$[i$];
        results$.push(func(value));
      }
      return results$;
    },
    fire: function(name, value){
      var node;
      switch (name) {
      case 'authpanel.on':
      case 'authpanel.off':
        node = document.querySelector('#auth-panel .cover-modal-wrapper');
        helper.removeClass(node, 'active');
        helper.removeClass(node, 'inactive');
        return helper.addClass(node, name === 'authpanel.on' ? 'active' : 'inactive');
      case 'signin':
        this.broadcast('user', value);
        return window.user = value, window.userkey = value.key, window;
      case 'signout':
        this.fire('loading.on');
        return this.broadcast('signout');
      case 'signout.done':
        this.broadcast('user', null);
        window.user = null;
        window.userkey = null;
        return this.fire('loading.off');
      case 'loading.on':
        return helper.addClass(document.body, 'running');
      case 'loading.off':
        return helper.removeClass(document.body, 'running');
      }
    }
  };
  if (nav) {
    navbar = controller.register(nav, main)[0];
  }
  authpanel = controller.register(auth, main)[0];
  consentpage = controller.register(consent, main)[0];
  controller.register(modal, main);
  profilePage = controller.register(profile, main)[0];
  main.broadcast('user', null);
  if (window.user) {
    return main.broadcast('user', window.user);
  }
});