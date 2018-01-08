<- $(document).ready

main = do
  fire: (name, value) ->
    switch name
    | 'authpanel.on' 'authpanel.off'
      document.querySelector('#auth-panel .cover-modal-wrapper').setAttribute("class",
        document.querySelector('#auth-panel .cover-modal-wrapper')
          .getAttribute("class")
          .replace(/ *(in)?active/g,'') + (if name == 'authpanel.on' => " active" else " inactive")
      )
    | 'login' => navbar.fire 'user', value

navbar = controller.register(nav, main) .0
authpanel = controller.register(auth, main) .0
controller.register(modal, main)

navbar.fire 'user', null
if window.user => navbar.fire 'user', window.user
