<- $(document).ready
if csrfToken? => $.ajaxSetup headers: {"X-CSRF-Token": csrfToken}

main = do
  monitor-list: {}
  monitor: (name, cb) -> @monitor-list[][name].push cb
  broadcast: (name, value) -> for func in @monitor-list[name] => func value
  fire: (name, value) ->
    switch name
    | 'authpanel.on' 'authpanel.off'
      node = document.querySelector('#auth-panel .cover-modal-wrapper')
      helper.remove-class node, 'active'
      helper.remove-class node, 'inactive'
      helper.add-class node, (if name == 'authpanel.on' => 'active' else 'inactive')
    | 'signin' =>
      @broadcast 'user', value
      window <<< {user: value, userkey: value.key}
    | 'signout' =>
      @fire 'loading.on'
      @broadcast 'signout'
    | 'signout.done' =>
      @broadcast 'user', null
      window <<< {user: null, userkey: null}
      @fire 'loading.off'
    | 'loading.on' => helper.add-class document.body, 'running'
    | 'loading.off' => helper.remove-class document.body, 'running'

navbar = controller.register(nav, main) .0
authpanel = controller.register(auth, main) .0
consentpage = controller.register(consent, main) .0
controller.register(modal, main)
profile-page = controller.register(profile, main) .0

main.broadcast 'user', null

if window.user => main.broadcast 'user', window.user

