profile = (dom, data, parent) ->
  @ <<< {dom, data}
  parent.monitor \user, (user) ~>
    @user = user
    @update user
  dom["update.info"].addEventListener \click, ~> @update-info!
  dom["update.passwd"].addEventListener \click, ~> @update-passwd!
  dom["jothon-app.create"].addEventListener \click, ~> @app-create!
  $.ajax url: \/d/me/jothon-app/, method: \GET
  .done (apps) ~>
    apps.map (item) ~>
      node = dom["jothon-app.template"].cloneNode true
      @app-dom-update node, item
    if apps.length => helper.toggle-class dom["jothon-app.none"], 'd-none', true

profile
  ..controller = 'profile'
  ..prototype <<< do
    running: (name, is-running = true) ->
      helper.toggle-class @dom[name], \running, is-running
    update: (user) ->
      if !user => return
      <[username displayname description]>.map ~> if user[it] => @set-text it, user[it]
      <[displayname description tags]>.map ~> if user[it] => @set it, user[it]
      <[tags website]>.map ~> if user.{}config[it] => @set it, user.config[it]
      @dom["tags"].innerHTML = user.{}config.tags.split \,
        .map -> "<div class='badge badge-light mr-1'>#it</div>"
        .join('')
      @dom["website"].setAttribute("href", user.{}config.website or "#")
      helper.toggle-class @dom["website"], "d-none", !user.{}config.website

    update-info: ->
      if !@user => return
      @running \update.info
      $.ajaxSetup headers: {"X-CSRF-Token": csrfToken}
      data = {
        displayname: @data.displayname, description: @data.description
        config: { website: @data.website, tags: @data.tags }
      }

      $.ajax url: "/d/user/#{@user.key}", method: \PUT, data: data
        .done ~>
          @running \update.info, false
          @update window.user <<< data
        .fail ~> 
          alert \failed
          @running \update.info, false

    update-passwd: ->
      if !@user => return
      if @data["password.new"] != @data["password.again"] => return alert "password mismatch"
      @running \update.passwd
      data = { n: @data["password.new"], o: @data["password.now"] }
      $.ajax url: \/d/me/passwd/, method: \PUT, data: data
      .done ~> @running \update.passwd, false
      .fail ~>
        alert \failed
        @running \update.passwd, false

    app-create: ->
      if !@user => return
      if !@data["appname"] or !@data["appcb"] => return alert "information incomplete"
      data = {name: @data["appname"], callback: @data["appcb"], avatar: @data["avatar"]}
      $.ajax url: \/d/me/jothon-app/, method: \POST, data: data
      .done ~> @running \jothon-app.create, false
      .fail ~>
        alert \failed
        @running \jothon-app.create, false

    app-delete: (node, key) ->
      if !@user => return alert "not logined"
      $.ajax url: "/d/me/jothon-app/#{key}", method: \DELETE
      .done ~>
        alert \ok
        @app-dom-update node, null, true
        helper.toggle-class @dom["jothon-app.none"], 'd-none', (
          if @dom.root.querySelectorAll \.jothon-app .length => false else true
        )

      .fail ~> alert \failed
    app-update: (item, node) ->
      if !@user => return alert "not logined"
      if !item["name"] or !item["callback"] => return alert "information incomplete"
      data = item{name, callback, avatar}
      $.ajax url: "/d/me/jothon-app/#{item.key}", method: \PUT, data: data
      .done ~>
        alert \ok
        @app-dom-update node, item
      .fail ~>
        alert \failed

    app-dom-update: (node, item, remove) ->
      if remove => return node.parentNode.removeChild node
      helper.toggle-class node, 'd-none', false
      node.querySelector \h3 .innerText = item.name
      inputs = Array.from(node.querySelectorAll \input)
      <[name callback avatar app_id app_secret]>.map (d,i) -> inputs[i].value = item[d]
      if item.avatar => node.querySelector \.avatar .style.backgroundImage = "url(#{item.avatar})"
      if node.parentNode == @dom["jothon-app.list"] => return
      @dom["jothon-app.list"].appendChild(node)
      node.querySelector \.jothon-app-update .addEventListener \click, ~>
        <[name callback avatar]>.map (d,i) -> item[d] = inputs[i].value
        @app-update item, node
      node.querySelector \.jothon-app-delete .addEventListener \click, ~> @app-delete node, item.key
      node.querySelector \.jothon-secret-show .addEventListener \click, ->
        @show = !!!@show
        node.querySelector \.secret .setAttribute \type, if @show => \text else \password
        @innerText = if @show => \hide else \show
