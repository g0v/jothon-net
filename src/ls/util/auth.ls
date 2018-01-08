auth = (dom, data, parent) ->
  @ <<< mode: 0, parent: parent
  dom["tab.signup"].addEventListener \click, ~> @tab 'signup'
  dom["tab.login"].addEventListener \click, ~> @tab 'login'
  dom["action"].addEventListener \click, ~> @signin @mode == 0

auth
  ..controller = 'auth'
  ..prototype <<< do
    tab: (name) ->
      tabs = <[signup login]>
      text = <[註冊 登入]>
      @mode = i = tabs.indexOf(name)
      @dom["tab.#{tabs[i]}"].setAttribute("class", "active nav-link")
      @dom["tab.#{tabs[1 - i]}"].setAttribute("class", "nav-link")
      @set-text \action, text[i]
      @dom["displayname"].style.display = if i => "none" else "block"
      @dom["newsletter"].style.display = if i => "none" else "block"
    error: (des, value) ->
      @set-text "error.#des", value
      @dom.model[des].setAttribute("class", "form-control is-invalid")
      @running false
    running: (is-running = true) ->
      @dom["action"].setAttribute("class",
        if is-running => @dom["action"].getAttribute("class") + " running"
        else @dom["action"].getAttribute("class").replace(/ *running */g, ' ')
      )

    signin: (is-signup = true) ->
      <[email displayname passwd]>.map ~> @dom.model[it].setAttribute("class", "form-control")
      if !/^[-a-z0-9~!$%^&*_=+}{\'?]+(\.[-a-z0-9~!$%^&*_=+}{\'?]+)*@([a-z0-9_][-a-z0-9_]*(\.[-a-z0-9_]+)*\.[a-z]{2,}|([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}))(:[0-9]{1,5})?$/i.exec(@data.email) =>
        return @error \email, "這不是電子郵件"
      else if is-signup and !@data.displayname =>
        return @error \displayname, "這個欄位為必填"
      else if !@data.passwd => return @error \passwd, "這個欄位為必填"
      else if @data.passwd.length < 4 => return @error \passwd, "密碼太弱"
      @running!
      $.ajax url: (if is-signup => \/u/signup else \/u/login), method: \POST, data: @data
        .done ~>
          @parent.fire 'authpanel.off'
          @parent.fire 'login', it
          @running false
        .fail ~>
          if it.status == 403 =>
            if is-signup => @error \email, "已經註冊過了"
            else @error \passwd, "密碼不符"
          else @error \email, "系統問題，請稍候再試"
