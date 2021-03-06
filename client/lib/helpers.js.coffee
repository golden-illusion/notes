window.okCancelEvents = (selector, callbacks) ->
  ok = callbacks.ok || ->
  cancel = callbacks.cancel || ->

  events = {}
  events["keyup #{selector}, keydown #{selector}"] = (evt) ->
    if evt.type is "keydown" and evt.which is 27
      cancel.call this, evt
    else if evt.type is "keyup" and evt.which is 13 or evt.type is "focusout"
      value = String(evt.target.value || "")
      if value then ok.call(@, value, evt) else cancel.call(@, evt) end
  events

window.confirmation = (params, callback)->
  $("#confirmation").modal("show")
  $("#confirmation .ok").one "click", ->
    callback(params)
    $("#confirmation").modal("hide")

window.openNote = (content)->
  $("#note-detail-modal").find("div.body").html(Autolinker.link(content))
  $("#note-detail-modal").modal("show")