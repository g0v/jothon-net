var nav, x$;
nav = function(dom, data, parent){
  var this$ = this;
  if (!dom["signin"]) {
    return;
  }
  dom["signin"].addEventListener('click', function(){
    return parent.fire('authpanel.on');
  });
  dom["signout"].addEventListener('click', function(){
    return parent.fire('signout');
  });
  return parent.monitor('user', function(it){
    this$.dom.signin.style.display = it ? 'none' : 'block';
    this$.dom.profile.style.display = it ? 'block' : 'none';
    return this$.setText('displayname', it ? it.displayname : '沒有人');
  });
};
x$ = nav;
x$.controller = 'nav';