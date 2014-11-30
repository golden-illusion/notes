Notes = new Mongo.Collection "notes"
Categories = new Mongo.Collection "categories"

Meteor.subscribe "categories", ->
  if !Session.get "category_id"
    Session.set "category_id", Categories.findOne {}, {sort: {name: 1}}

Tracker.autorun ->
  Meteor.subscribe "notes", Session.get("category_id")

Session.setDefault("editing_note", null)
Session.setDefault("inserting_note", null)

Template.noteList.helpers
  notes: ->
    Notes.find {category_id: Session.get("category_id")}

Template.categoryForm.helpers
  categories: ->
    Categories.find {}

Template.categoryForm.events(window.okCancelEvents(
  "#create-category"
    ok: (title, evt)->
      category = Meteor.call "createCategory", title, (err, category_id)->
        Session.set "category_id", category_id
      evt.target.value = ""
))

Template.categoryForm.events
  "click .list-group-item": (evt)->
    Session.set "category_id", this._id
  "click .btn-warning": ->
    Session.set "category_id", Categories.findOne()._id
    Meteor.call "removeCategory", this._id

Template.categoryForm.selected = ->
  if Session.equals("category_id", this._id) then "active" else ""

Template.noteForm.events
  "click #create-note": (e, template) ->
    Session.set("inserting_note", this._id)
    Tracker.flush()
    template.find("#input-content").focus()
    template.find("#input-content").select()

Template.noteItem.events
  "click .remove": ->
    Meteor.call "removeNote", this._id
  "dblclick .note-content": (event, template) ->
    Session.set "editing_note", this._id
    Tracker.flush()
    template.find("#input-content").focus()
    template.find("#input-content").select()

Template.noteItem.events(window.okCancelEvents(
  "#input-content"
    ok: (content, event) ->
      Session.set "editing_note", null
      Meteor.call "updateNote", this._id, content
    cancel: ->
      Session.set "editing_note", null
))

Template.noteForm.events(window.okCancelEvents(
  "#input-content"
    ok: (content, event) ->
      Session.set("inserting_note", null)
      Meteor.call("createNote", content, Session.get("category_id"))
    cancel: ->
      Session.set("inserting_note", null)
))

Template.noteItem.editing = ->
  Session.equals "editing_note", this._id

Template.noteForm.inserting = ->
  Session.equals("inserting_note", this._id)

Template.noteItem.content = ->
  Autolinker.link this.content
