(function(){
  var errcode, backend, e, x$;
  errcode = function(str, option){};
  if (typeof angular != 'undefined' && angular !== null) {
    try {
      backend = angular.module('loadingIO');
    } catch (e$) {
      e = e$;
      backend = angular.module('loadingIO', []);
    }
    x$ = backend;
    x$.factory('errcode', [].concat(function(){
      return errcode;
    }));
    return x$;
  } else if (typeof module != 'undefined' && module !== null) {
    return module.exports = errcode;
  }
})();