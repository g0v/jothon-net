var auth, x$;
auth = function(dom, data, parent){
  var this$ = this;
  this.mode = 0;
  this.parent = parent;
  dom["tab.signup"].addEventListener('click', function(){
    return this$.tab('signup');
  });
  dom["tab.login"].addEventListener('click', function(){
    return this$.tab('login');
  });
  dom["action"].addEventListener('click', function(){
    return this$.signin(this$.mode === 0);
  });
  dom["closebtn"].addEventListener('click', function(){
    return parent.fire('authpanel.off');
  });
  return parent.monitor('signout', function(){
    return this$.signout();
  });
};
x$ = auth;
x$.controller = 'auth';
import$(x$.prototype, {
  tab: function(name){
    var tabs, text, i;
    tabs = ['signup', 'login'];
    text = ["註冊 / Sign Up", "登入 / Login"];
    this.mode = i = tabs.indexOf(name);
    helper.addClass(this.dom["tab." + tabs[i]], 'active');
    helper.removeClass(this.dom["tab." + tabs[1 - i]], 'active');
    this.setText('action', text[i]);
    this.dom["displayname"].style.display = i ? "none" : "block";
    return this.dom["newsletter"].style.display = i ? "none" : "block";
  },
  error: function(des, value){
    this.setText("error." + des, value);
    helper.addClass(this.dom.model[des], 'is-invalid');
    return this.running(false);
  },
  running: function(isRunning){
    isRunning == null && (isRunning = true);
    helper.addClass(this.dom["action"], 'running');
    helper.removeClass(this.dom["action"], 'running');
    return helper.toggleClass(this.dom["action"], 'running', isRunning);
  },
  signout: function(){
    var this$ = this;
    return $.ajax({
      url: '/u/logout',
      method: 'GET'
    }).done(function(){
      return this$.parent.fire('signout.done');
    });
  },
  signin: function(isSignup){
    var this$ = this;
    isSignup == null && (isSignup = true);
    ['email', 'displayname', 'passwd'].map(function(it){
      return helper.removeClass(this$.dom.model[it], 'is-invalid');
    });
    if (!/^[-a-z0-9~!$%^&*_=+}{\'?]+(\.[-a-z0-9~!$%^&*_=+}{\'?]+)*@([a-z0-9_][-a-z0-9_]*(\.[-a-z0-9_]+)*\.[a-z]{2,}|([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}))(:[0-9]{1,5})?$/i.exec(this.data.email)) {
      return this.error('email', "這不是電子郵件");
    } else if (isSignup && !this.data.displayname) {
      return this.error('displayname', "這個欄位為必填");
    } else if (!this.data.passwd) {
      return this.error('passwd', "這個欄位為必填");
    } else if (this.data.passwd.length < 4) {
      return this.error('passwd', "密碼太弱");
    }
    this.running();
    return $.ajax({
      url: isSignup ? '/u/signup' : '/u/login',
      method: 'POST',
      data: this.data
    }).done(function(it){
      this$.parent.fire('authpanel.off');
      this$.parent.fire('signin', it);
      if (/\/openid\/i/.exec(window.location.pathname)) {
        return window.location.href = window.location.pathname + "";
      } else {
        return this$.running(false);
      }
    }).fail(function(it){
      if (it.status === 403) {
        if (isSignup) {
          return this$.error('email', "已經註冊過了");
        } else {
          return this$.error('passwd', "密碼不符");
        }
      } else {
        return this$.error('email', "系統問題，請稍候再試");
      }
    });
  }
});
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}