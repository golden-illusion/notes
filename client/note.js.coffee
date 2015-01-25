Notes = new Mongo.Collection "notes"

Tracker.autorun ->
  Meteor.subscribe "notes", Session.get("category_id"), Meteor.userId()

Session.setDefault("editing_note", null)
Session.setDefault("inserting_note", null)

Template.noteList.helpers
  notes: ->
    notes = Notes.find({category_id: Session.get("category_id"), userId: Meteor.userId()}).fetch()
    _.each(notes, (note)->
      note.header = ->
        "#{this.content.substring(0,60)}..."
    )
    notes

Template.noteList.events
  "click .remove-selected": (e) ->
    confirmation {_id: {$in: Session.get("selected_notes")}}, (query)->
      Meteor.call("removeNote", query)
      Session.set("selected_notes", [])

Template.noteForm.events
  "click #create-note": (e, template) ->
    Session.set("inserting_note", this._id)
    Tracker.flush()
    template.find("#input-content").focus()
    template.find("#input-content").select()
  "click #save-note": (e, template) ->
    content = template.find("#input-content").value
    if content != ""
      Meteor.call("createNote", content, Session.get("category_id"))
    Session.set("inserting_note", null)

Template.noteForm.events window.okCancelEvents(
  "#input-content"
    cancel: ->
      Session.set "inserting_note", null
)

Template.noteItem.events
  "click .remove": ->
    confirmation this._id, (id)->
      Meteor.call "removeNote", {_id: id}
  "click .edit-note, dblclick .note-content": (event, template) ->
    Session.set "editing_note", this._id
    Tracker.flush()
    template.find("#input-content").focus()
    template.find("#input-content").select()
  "change .note-item": (e)->
    if e.target.checked
      selected_notes = Session.get("selected_notes")
      selected_notes ||= []
      selected_notes.push(this._id)
    else
      selected_notes = Session.get("selected_notes")
      selected_notes ||= []
      index = selected_notes.indexOf(this._id)
      selected_notes.splice(index, 1)
    Session.set("selected_notes", selected_notes)
  "click .submit-note": (e)->
    content = $(e.target).parent().parent().prev().find("#input-content").val()
    Meteor.call "updateNote", this._id, {$set: {content: content}}
    Session.set "editing_note", null

Template.noteItem.events window.okCancelEvents(
  "#input-content"
    cancel: ->
      Session.set "editing_note", null
)

Template.noteItem.helpers
  editing: ->
    Session.equals "editing_note", this._id
  # content: ->
  #   Autolinker.link this.content

Template.noteForm.helpers
  inserting: ->
    Session.equals("inserting_note", this._id)