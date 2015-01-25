Notes = new Mongo.Collection "notes"
Categories = new Mongo.Collection "categories"

Tracker.autorun ->
  Meteor.subscribe "categories", Meteor.userId(), ->
    if !Session.get("category_id")
      first_cate = Categories.findOne({userId: Meteor.userId()})
      if first_cate != undefined
        Session.set "category_id", first_cate._id, {sort: {name: 1}}
      else
        Meteor.call "createCategory", "uncategory", (err, category_id)->
          Session.set "category_id", category_id

Tracker.autorun ->
  Meteor.subscribe "notes", Session.get("category_id"), Meteor.userId()

Session.setDefault("editing_note", null)
Session.setDefault("inserting_note", null)
Session.setDefault("editing_category", null)

Template.noteList.helpers
  notes: ->
    notes = Notes.find({category_id: Session.get("category_id"), userId: Meteor.userId()}).fetch()
    _.each(notes, (note)->
      note.header = ->
        this.content.substring(0,30)
    )
    notes

Template.categoryModal.helpers
  categories: ->
    Categories.find {userId: Meteor.userId()}

Template.categoryModal.events
  "click .btn-move": (e)->
    category_id = $("#category-list").val()
    selected_notes = Session.get("selected_notes")
    selected_notes ||= []
    Meteor.call("updateNote", {_id: {$in: selected_notes}}, {$set: {category_id: category_id}}, {multi: true})
    Session.set("selected_notes", [])
    $("#category-modal").modal("hide")

Template.noteList.events
  "click .remove-selected": (e) ->
    confirmation {_id: {$in: Session.get("selected_notes")}}, (query)->
      Meteor.call("removeNote", query)
      Session.set("selected_notes", [])

Template.categoryForm.helpers
  categories: ->
    Categories.find {userId: Meteor.userId()}

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
  "click .remove-category": ->
    Session.set "category_id", Categories.findOne()._id
    Meteor.call "removeCategory", this._id

Template.categoryItem.events
  "click .edit-category": ->
    Session.set("editing_category", this._id)
  "click .submit-category": (e)->
    title = $(e.target).parent().parent().find(".category-input").val()
    Meteor.call("updateCategory", this._id, {$set: {title: title}})
    Session.set("editing_category", null)

Template.categoryItem.helpers
  editing: ->
    Session.equals "editing_category", this._id

Template.categoryItem.selected = ->
  if Session.equals("category_id", this._id) then "active" else ""

Template.noteForm.events
  "click #create-note": (e, template) ->
    Session.set("inserting_note", this._id)
    Tracker.flush()
    template.find("#input-content").focus()
    template.find("#input-content").select()
  "click #save-note": (e, template) ->
    Meteor.call("createNote", template.find("#input-content").value, Session.get("category_id"))
    Session.set("inserting_note", null)

Template.noteItem.events
  "click .remove": ->
    confirmation this._id, (id)->
      Meteor.call "removeNote", {_id: id}
  "dblclick .note-content": (event, template) ->
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


Template.noteItem.events(window.okCancelEvents(
  "#input-content"
    ok: (content, event) ->
      Session.set "editing_note", null
      Meteor.call "updateNote", this._id, {$set: {content: content}}
    cancel: ->
      Session.set "editing_note", null
))

Template.noteItem.editing = ->
  Session.equals "editing_note", this._id

Template.noteForm.inserting = ->
  Session.equals("inserting_note", this._id)

Template.noteItem.content = ->
  Autolinker.link this.content

confirmation = (params, callback)->
  $("#confirmation").modal("show")
  $("#confirmation .ok").one "click", ->
    callback(params)
    $("#confirmation").modal("hide")