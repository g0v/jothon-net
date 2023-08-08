var modal, x$;
modal = function(dom, data){
  return dom["mask"].addEventListener('click', function(){
    helper.removeClass(dom.root, 'active');
    return helper.addClass(dom.root, 'inactive');
  });
};
x$ = modal;
x$.controller = 'modal';