consent = (dom, data, parent) ->
  dom["consent"].addEventListener \click, ~> @consent true

consent
  ..controller = 'consent'
  ..prototype <<< do
    consent: (accept) ->
      if !/\/openid\/i/.exec(window.location.pathname) => return
      $.ajax url: "#{window.location.pathname}/consent", method: \POST
        .done ~> window.location.href = "#{window.location.pathname}"
