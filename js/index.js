var x$;
x$ = angular.module('servlet', ['ldBase', 'backend']);
x$.factory('httpRequestInterceptor', ['global'].concat(function(global){
  return {
    request: function(config){
      config.headers['X-CSRF-Token'] = global.csrfToken;
      return config;
    }
  };
}));
x$.config(['$compileProvider', '$httpProvider'].concat(function($compileProvider, $httpProvider){
  $compileProvider.aHrefSanitizationWhitelist(/^\s*(blob:|http:\/\/localhost)/);
  return $httpProvider.interceptors.push('httpRequestInterceptor');
}));
x$.controller('site', ['$scope', '$http', '$interval', 'global', 'ldBase', 'ldNotify', 'initWrap'].concat(function($scope, $http, $interval, global, ldBase, ldNotify, initWrap){
  initWrap = initWrap();
  import$($scope, ldBase);
  $scope.notifications = ldNotify.queue;
  $scope.staticMode = global['static'];
  $scope.$watch('user.data', function(n, o){
    if (!n || !n.key) {
      return;
    }
    $scope.track("uv/" + n.key, new Date().toISOString().substring(0, 10) + "", window.location.pathname);
    return ga('set', 'dimension1', n.key);
  }, true);
  $scope.user = {
    data: global.user
  };
  $scope.auth = initWrap({
    init: function(){
      var this$ = this;
      return $scope.$watch('auth.ctrl.toggled', function(){
        return this$.error = {};
      });
    },
    email: '',
    displayname: '',
    passwd: '',
    stick: false,
    subscribe: true,
    config: {
      dismissOnEnter: false,
      finish: function(){
        return $scope.auth.login();
      }
    },
    verify: function(){
      this.error = {};
      return !/^[-a-z0-9~!$%^&*_=+}{\'?]+(\.[-a-z0-9~!$%^&*_=+}{\'?]+)*@([a-z0-9_][-a-z0-9_]*(\.[-a-z0-9_]+)*\.[a-z]{2,}|([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}))(:[0-9]{1,5})?$/i.exec(this.email)
        ? this.error.email = "this is not an email"
        : !this.isSignIn && (!this.displayname || this.displayname.length < 3)
          ? this.error.displayname = "it's too short"
          : !this.passwd || this.passwd.length < 4 ? this.error.passwd = "it's too weak!" : 0;
    },
    logout: function(){
      console.log('logout..');
      return $http({
        url: '/u/logout',
        method: 'GET'
      }).success(function(d){
        console.log('logouted.');
        $scope.user.data = null;
        return window.location.reload();
      }).error(function(d){
        return ldNotify.send('danger', 'Failed to Logout. ');
      });
    },
    login: function(){
      var config, this$ = this;
      if (this.verify()) {
        return;
      }
      this.loading = true;
      config = {
        newsletter: this.subscribe
      };
      $http({
        url: this.isSignIn ? '/u/login' : '/u/signup',
        method: 'POST',
        data: $.param(import$({
          email: this.email,
          passwd: this.passwd,
          displayname: this.displayname
        }, this.isSignIn
          ? {}
          : {
            config: config
          })),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
        }
      })['finally'](function(){
        return this$.loading = false;
      }).then(function(d){
        $scope.user.data = d.data;
        ga('set', '&uid', d.key);
        this$.ctrl.toggle(false);
        if ($scope.nexturl) {
          return window.location.href = $scope.nexturl;
        } else if (window.location.pathname === '/u/login') {
          return window.location.href = '/';
        }
      })['catch'](function(d){
        if (d.status === 403) {
          if (this$.isSignIn) {
            return this$.error.passwd = 'wrong password';
          } else {
            return this$.error.email = 'this email is used before.';
          }
        } else {
          return this$.error.email = 'system busy, try again later.';
        }
      });
      return this.passwd = "";
    }
  });
  initWrap.run();
  return console.log('loaded');
}));
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}