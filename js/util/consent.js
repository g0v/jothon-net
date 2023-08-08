var consent, x$;
consent = function(dom, data, parent){
  var this$ = this;
  return dom["consent"].addEventListener('click', function(){
    return this$.consent(true);
  });
};
x$ = consent;
x$.controller = 'consent';
import$(x$.prototype, {
  consent: function(accept){
    if (!/\/openid\/i/.exec(window.location.pathname)) {
      return;
    }
    return $.ajax({
      url: window.location.pathname + "/consent",
      method: 'POST'
    }).done(function(){
      return window.location.href = window.location.pathname + "";
    });
  }
});
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}