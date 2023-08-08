var profile, x$;
profile = function(dom, data, parent){
  var this$ = this;
  this.dom = dom;
  this.data = data;
  parent.monitor('user', function(user){
    this$.user = user;
    return this$.update(user);
  });
  dom["update.info"].addEventListener('click', function(){
    return this$.updateInfo();
  });
  dom["update.passwd"].addEventListener('click', function(){
    return this$.updatePasswd();
  });
  dom["jothon-app.create"].addEventListener('click', function(){
    return this$.appCreate();
  });
  return $.ajax({
    url: '/d/me/jothon-app/',
    method: 'GET'
  }).done(function(apps){
    apps.map(function(item){
      var node;
      node = dom["jothon-app.template"].cloneNode(true);
      return this$.appDomUpdate(node, item);
    });
    if (apps.length) {
      return helper.toggleClass(dom["jothon-app.none"], 'd-none', true);
    }
  });
};
x$ = profile;
x$.controller = 'profile';
import$(x$.prototype, {
  running: function(name, isRunning){
    isRunning == null && (isRunning = true);
    return helper.toggleClass(this.dom[name], 'running', isRunning);
  },
  update: function(user){
    var this$ = this;
    if (!user) {
      return;
    }
    ['username', 'displayname', 'description'].map(function(it){
      if (user[it]) {
        return this$.setText(it, user[it]);
      }
    });
    ['displayname', 'description', 'tags'].map(function(it){
      if (user[it]) {
        return this$.set(it, user[it]);
      }
    });
    ['tags', 'website'].map(function(it){
      if ((user.config || (user.config = {}))[it]) {
        return this$.set(it, user.config[it]);
      }
    });
    this.dom["tags"].innerHTML = (user.config || (user.config = {})).tags.split(',').map(function(it){
      return "<div class='badge badge-light mr-1'>" + it + "</div>";
    }).join('');
    this.dom["website"].setAttribute("href", (user.config || (user.config = {})).website || "#");
    return helper.toggleClass(this.dom["website"], "d-none", !(user.config || (user.config = {})).website);
  },
  updateInfo: function(){
    var data, this$ = this;
    if (!this.user) {
      return;
    }
    this.running('update.info');
    $.ajaxSetup({
      headers: {
        "X-CSRF-Token": csrfToken
      }
    });
    data = {
      displayname: this.data.displayname,
      description: this.data.description,
      config: {
        website: this.data.website,
        tags: this.data.tags
      }
    };
    return $.ajax({
      url: "/d/user/" + this.user.key,
      method: 'PUT',
      data: data
    }).done(function(){
      this$.running('update.info', false);
      return this$.update(import$(window.user, data));
    }).fail(function(){
      alert('failed');
      return this$.running('update.info', false);
    });
  },
  updatePasswd: function(){
    var data, this$ = this;
    if (!this.user) {
      return;
    }
    if (this.data["password.new"] !== this.data["password.again"]) {
      return alert("password mismatch");
    }
    this.running('update.passwd');
    data = {
      n: this.data["password.new"],
      o: this.data["password.now"]
    };
    return $.ajax({
      url: '/d/me/passwd/',
      method: 'PUT',
      data: data
    }).done(function(){
      return this$.running('update.passwd', false);
    }).fail(function(){
      alert('failed');
      return this$.running('update.passwd', false);
    });
  },
  appCreate: function(){
    var data, this$ = this;
    if (!this.user) {
      return;
    }
    if (!this.data["appname"] || !this.data["appcb"]) {
      return alert("information incomplete");
    }
    data = {
      name: this.data["appname"],
      callback: this.data["appcb"],
      avatar: this.data["avatar"]
    };
    return $.ajax({
      url: '/d/me/jothon-app/',
      method: 'POST',
      data: data
    }).done(function(){
      return this$.running('jothon-app.create', false);
    }).fail(function(){
      alert('failed');
      return this$.running('jothon-app.create', false);
    });
  },
  appDelete: function(node, key){
    var this$ = this;
    if (!this.user) {
      return alert("not logined");
    }
    return $.ajax({
      url: "/d/me/jothon-app/" + key,
      method: 'DELETE'
    }).done(function(){
      alert('ok');
      this$.appDomUpdate(node, null, true);
      return helper.toggleClass(this$.dom["jothon-app.none"], 'd-none', this$.dom.root.querySelectorAll('.jothon-app').length ? false : true);
    }).fail(function(){
      return alert('failed');
    });
  },
  appUpdate: function(item, node){
    var data, this$ = this;
    if (!this.user) {
      return alert("not logined");
    }
    if (!item["name"] || !item["callback"]) {
      return alert("information incomplete");
    }
    data = {
      name: item.name,
      callback: item.callback,
      avatar: item.avatar
    };
    return $.ajax({
      url: "/d/me/jothon-app/" + item.key,
      method: 'PUT',
      data: data
    }).done(function(){
      alert('ok');
      return this$.appDomUpdate(node, item);
    }).fail(function(){
      return alert('failed');
    });
  },
  appDomUpdate: function(node, item, remove){
    var inputs, this$ = this;
    if (remove) {
      return node.parentNode.removeChild(node);
    }
    helper.toggleClass(node, 'd-none', false);
    node.querySelector('h3').innerText = item.name;
    inputs = Array.from(node.querySelectorAll('input'));
    ['name', 'callback', 'avatar', 'app_id', 'app_secret'].map(function(d, i){
      return inputs[i].value = item[d];
    });
    if (item.avatar) {
      node.querySelector('.avatar').style.backgroundImage = "url(" + item.avatar + ")";
    }
    if (node.parentNode === this.dom["jothon-app.list"]) {
      return;
    }
    this.dom["jothon-app.list"].appendChild(node);
    node.querySelector('.jothon-app-update').addEventListener('click', function(){
      ['name', 'callback', 'avatar'].map(function(d, i){
        return item[d] = inputs[i].value;
      });
      return this$.appUpdate(item, node);
    });
    node.querySelector('.jothon-app-delete').addEventListener('click', function(){
      return this$.appDelete(node, item.key);
    });
    return node.querySelector('.jothon-secret-show').addEventListener('click', function(){
      this.show = !this.show;
      node.querySelector('.secret').setAttribute('type', this.show ? 'text' : 'password');
      return this.innerText = this.show ? 'hide' : 'show';
    });
  }
});
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}