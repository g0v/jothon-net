<- $(document).ready

main = do
  fire: (name, value) ->
    switch name
    | 'authpanel.on' 'authpanel.off'
      node = document.querySelector('#auth-panel .cover-modal-wrapper')
      helper.remove-class node, 'active'
      helper.remove-class node, 'inactive'
      helper.add-class node, (if name == 'authpanel.on' => 'active' else 'inactive')
    | 'signin' => navbar.fire 'user', value
    | 'signout' =>
      @fire 'loading.on'
      authpanel.fire 'signout'
    | 'signout.done' =>
      navbar.fire 'user', null
      window <<< {user: null, userkey: null}
      @fire 'loading.off'
    | 'loading.on' => helper.add-class document.body, 'running'
    | 'loading.off' => helper.remove-class document.body, 'running'

navbar = controller.register(nav, main) .0
authpanel = controller.register(auth, main) .0
controller.register(modal, main)

navbar.fire 'user', null
if window.user => navbar.fire 'user', window.user
