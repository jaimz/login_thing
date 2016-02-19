class TextWidget
  (@is-password = false, el) ->
    unless el?
      @dom-fragment = @_create-dom-fragment!
    else
      @dom-fragment = el