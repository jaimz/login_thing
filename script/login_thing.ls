kDefaultUserId = "primary"
kDebounceDefault = 700ms

_ = Bacon

text-field-value = (text-field) ->
  value = -> text-field.value
  changes = (_.fromEventTarget text-field, 'change')
  (_.fromEventTarget text-field, 'keyup').debounceImmediate(500).merge(changes).map(value).toProperty(value())

set-attr = (node, attr-name, attr-value) ->
  if attr-value is false
    node.remove-attribute attr-name
  else
    node.set-attribute attr-name, attr-value


class UserCard
  (@RootView = document.get-element-by-id kDefaultUserId) ->
    if @RootView?
      @username-ipt = @RootView.query-selector "input[name=username]"
      @password-ipt = @RootView.query-selector "input[name=password]"
      @do-login-button = @RootView.query-selector "button[name=submit-login]"
      @do-logout-button = @RootView.query-selector "button[name=sign-out]"
      @avatar-coin = @RootView.query-selector ".avatar"
      @login-dialog = @RootView.query-selector ".login.dialog"

      # DEBUG
      @avatar-coin.add-event-listener 'click', (e) !~> @RootView.class-list.toggle "will-login"

      @_username = text-field-value @username-ipt
      @_password = text-field-value @password-ipt

      nonempty = (x) -> x.length > 0

      @_looking-up-avatar = false
      @_avatar-lookup-timer = null
      @_have-avatar = false
      @_username.onValue @lookup-avatar

      username-entered = @_username.map(nonempty)
      password-entered = @_password.map(nonempty)
      login-enabled = username-entered.and(password-entered)
      login-enabled.onValue (enabled) !~> set-attr @do-login-button, 'disabled', !enabled

      if @login-dialog?
        @login-dialog.add-event-listener "submit", @start-login

      if @do-logout-button?
        @do-logout-button.add-event-listener "click", @do-logout
    else
      console.error "Was not supplied with user card (and could not find #{kDefaultUserId}"
      return

  lookup-avatar: (username) !~>
    if @_avatar-lookup-timer?
      clear-timeout @_looking-up-avatar

    if username.length > 0 and @_have-avatar is false
      @avatar-coin.class-list.add 'searching'
      @_avatar-lookup-timer = set-timeout @show-avatar, 1000

  show-avatar: !~>
    @avatar-coin.class-list.remove 'searching'
    @avatar-coin.class-list.add 'with-image'
    @_have-avatar = true

  start-login: (e) ~>
    @RootView.class-list.add 'will-login'
    set-timeout @did-login, 3000
    false

  did-login: !~>
    @username-ipt.value = ""
    @password-ipt.value = ""
    @RootView.class-list.remove "will-login"
    @RootView.class-list.add "did-login"
    set-timeout @did-get-info, 1500

  did-get-info: !~>
    @RootView.class-list.add "did-get-info"

  do-logout: !~>
    @avatar-coin.class-list.remove "with-image"
    @RootView.class-list.remove "did-login"
    @RootView.class-list.remove "did-get-info"
    @_have-avatar = false

init = ->
  window.userCard = new UserCard()

document.add-event-listener "DOMContentLoaded", init