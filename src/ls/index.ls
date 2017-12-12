angular.module \servlet, <[ldBase backend]>
  ..factory \httpRequestInterceptor, <[global]> ++ (global) -> do
    request: (config) ->
      config.headers['X-CSRF-Token'] = global.csrfToken
      config
  ..config <[$compileProvider $httpProvider]> ++ ($compileProvider, $httpProvider) ->
    $compileProvider.aHrefSanitizationWhitelist(/^\s*(blob:|http:\/\/localhost)/)
    $httpProvider.interceptors.push \httpRequestInterceptor
  ..controller \site, <[$scope $http $interval global ldBase ldNotify initWrap]> ++
    ($scope, $http, $interval, global, ldBase, ldNotify, initWrap) ->
    initWrap = initWrap!
    $scope <<< ldBase
    $scope.notifications = ldNotify.queue
    $scope.static-mode = global.static
    $scope.$watch 'user.data', ((n,o) ->
      if !n or !n.key => return
      $scope.track "uv/#{n.key}", "#{new Date!toISOString!substring 0,10}", window.location.pathname
      ga \set, \dimension1, n.key
    ), true
    $scope.user = data: global.user

    $scope.auth = initWrap do
      init: -> $scope.$watch 'auth.ctrl.toggled', ~> @error = {}
      email: '', displayname: '', passwd: ''
      stick: false
      subscribe: true
      config: do
        dismissOnEnter: false
        finish: -> $scope.auth.login!
      verify: ->
        @error = {}
        return if !/^[-a-z0-9~!$%^&*_=+}{\'?]+(\.[-a-z0-9~!$%^&*_=+}{\'?]+)*@([a-z0-9_][-a-z0-9_]*(\.[-a-z0-9_]+)*\.[a-z]{2,}|([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}))(:[0-9]{1,5})?$/i.exec(@email) =>
          @error.email = "this is not an email"
        else if !@isSignIn and (!@displayname or @displayname.length < 3) =>
          @error.displayname = "it's too short"
        else if !@passwd or @passwd.length < 4 =>
          @error.passwd = "it's too weak!"
        else 0
      logout: ->
        console.log \logout..
        $http do
          url: \/u/logout
          method: \GET
        .success (d) ->
          console.log \logouted.
          $scope.user.data = null
          window.location.reload!
        .error (d) ->
          ldNotify.send \danger, 'Failed to Logout. '
      login: ->
        if @verify! => return
        @loading = true
        config = {newsletter: @subscribe}
        $http do
          url: (if @isSignIn => \/u/login else \/u/signup)
          method: \POST
          data: $.param {
            email: @email, passwd: @passwd, displayname: @displayname
          } <<< (if @isSignIn => {} else {config: config})
          headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'}
        .finally ~> @loading = false
        .then (d) ~>
          $scope.user.data = d.data
          ga \set, \&uid, d.key
          @ctrl.toggle false
          if $scope.nexturl => window.location.href = $scope.nexturl
          else if window.location.pathname == '/u/login' => window.location.href = '/'
        .catch (d) ~> 
          if d.status == 403 => 
            if @isSignIn => @error.passwd = 'wrong password'
            else @error.email = 'this email is used before.'
          else => @error.email = 'system busy, try again later.'
        @passwd = ""

    initWrap.run!
    console.log \loaded
