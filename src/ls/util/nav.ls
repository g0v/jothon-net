nav = (dom, data, parent) ->
  dom["signin"].addEventListener \click, ~> parent.fire \authpanel.on
  dom["signout"].addEventListener \click, ~> parent.fire \signout
  parent.monitor 'user', ~>
    @dom.signin.style.display = if it => \none else \block
    @dom.profile.style.display = if it => \block else \none
    @set-text 'displayname', if it => it.displayname else \沒有人

nav
  ..controller = 'nav'
