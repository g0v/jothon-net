function import$(t,a){var n={}.hasOwnProperty;for(var e in a)n.call(a,e)&&(t[e]=a[e]);return t}var profile,x$;profile=function(t,a,n){var e=this;return this.dom=t,this.data=a,n.monitor("user",function(t){return e.user=t,e.update(t)}),t["update.info"].addEventListener("click",function(){return e.updateInfo()}),t["update.passwd"].addEventListener("click",function(){return e.updatePasswd()}),t["jothon-app.create"].addEventListener("click",function(){return e.appCreate()}),$.ajax({url:"/d/me/jothon-app/",method:"GET"}).done(function(a){if(a.map(function(a){var n;return n=t["jothon-app.template"].cloneNode(!0),e.appDomUpdate(n,a)}),a.length)return helper.toggleClass(t["jothon-app.none"],"d-none",!0)})},x$=profile,x$.controller="profile",import$(x$.prototype,{running:function(t,a){return null==a&&(a=!0),helper.toggleClass(this.dom[t],"running",a)},update:function(t){var a=this;if(t)return["username","displayname","description"].map(function(n){if(t[n])return a.setText(n,t[n])}),["displayname","description","tags"].map(function(n){if(t[n])return a.set(n,t[n])}),["tags","website"].map(function(n){if((t.config||(t.config={}))[n])return a.set(n,t.config[n])}),this.dom.tags.innerHTML=(t.config||(t.config={})).tags.split(",").map(function(t){return"<div class='badge badge-light mr-1'>"+t+"</div>"}).join(""),this.dom.website.setAttribute("href",(t.config||(t.config={})).website||"#"),helper.toggleClass(this.dom.website,"d-none",!(t.config||(t.config={})).website)},updateInfo:function(){var t,a=this;if(this.user)return this.running("update.info"),$.ajaxSetup({headers:{"X-CSRF-Token":csrfToken}}),t={displayname:this.data.displayname,description:this.data.description,config:{website:this.data.website,tags:this.data.tags}},$.ajax({url:"/d/user/"+this.user.key,method:"PUT",data:t}).done(function(){return a.running("update.info",!1),a.update(import$(window.user,t))}).fail(function(){return alert("failed"),a.running("update.info",!1)})},updatePasswd:function(){var t,a=this;if(this.user)return this.data["password.new"]!==this.data["password.again"]?alert("password mismatch"):(this.running("update.passwd"),t={n:this.data["password.new"],o:this.data["password.now"]},$.ajax({url:"/d/me/passwd/",method:"PUT",data:t}).done(function(){return a.running("update.passwd",!1)}).fail(function(){return alert("failed"),a.running("update.passwd",!1)}))},appCreate:function(){var t,a=this;if(this.user)return this.data.appname&&this.data.appcb?(t={name:this.data.appname,callback:this.data.appcb,avatar:this.data.avatar},$.ajax({url:"/d/me/jothon-app/",method:"POST",data:t}).done(function(){return a.running("jothon-app.create",!1)}).fail(function(){return alert("failed"),a.running("jothon-app.create",!1)})):alert("information incomplete")},appUpdate:function(t,a){var n,e=this;return this.user?t.name&&t.callback?(n={name:t.name,callback:t.callback,avatar:t.avatar},$.ajax({url:"/d/me/jothon-app/"+t.key,method:"PUT",data:n}).done(function(){return e.appDomUpdate(a,t)}).fail(function(){return alert("failed")})):alert("information incomplete"):alert("not logined")},appDomUpdate:function(t,a){var n,e,r=this;if(helper.toggleClass(t,"d-none",!1),t.querySelector("h3").innerText=a.name,n=Array.from(t.querySelectorAll("input")),["name","callback","avatar","app_id","app_secret"].map(function(t,e){return n[e].value=a[t]}),a.avatar&&(t.querySelector(".avatar").style.backgroundImage="url("+a.avatar+")"),t.parentNode!==this.dom["jothon-app.list"])return this.dom["jothon-app.list"].appendChild(t),e=t.querySelector(".btn"),e.addEventListener("click",function(){return["name","callback","avatar"].map(function(t,e){return a[t]=n[e].value}),r.appUpdate(a,t)})}});