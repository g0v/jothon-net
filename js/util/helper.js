var helper;
helper = {
  addClass: function(node, cls){
    return node.setAttribute('class', node.getAttribute('class').split(' ').filter(function(it){
      return it !== cls;
    }).join(' ') + (" " + cls));
  },
  removeClass: function(node, cls){
    return node.setAttribute('class', node.getAttribute('class').split(' ').filter(function(it){
      return it !== cls;
    }).join(' '));
  },
  toggleClass: function(node, cls, toggle){
    return (toggle
      ? this.addClass
      : this.removeClass)(node, cls);
  },
  findClass: function(node, cls){
    return !!node.getAttribute('class').split(' ').filter(function(it){
      return it === cls;
    }).length;
  }
};