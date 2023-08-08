(function(){
  var req, x$;
  req = {
    'static': true
  };
  if (typeof angular != 'undefined' && angular !== null) {
    if (window._backend_) {
      return angular.module('backend');
    } else {
      x$ = angular.module('backend', []);
      x$.factory('global', [].concat(function(){
        return req;
      }));
      return x$;
    }
  }
})();