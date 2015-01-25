Categories = new Mongo.Collection "categories"

Session.setDefault("editing_category", null)

Tracker.autorun ->
  Meteor.subscribe "categories", Meteor.userId(), ->
    if !Session.get("category_id")
      first_cate = Categories.findOne({userId: Meteor.userId()})
      if first_cate != undefined
        Session.set "category_id", first_cate._id, {sort: {name: 1}}
      else
        Meteor.call "createCategory", "uncategory", (err, category_id)->
          Session.set "category_id", category_id

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
    confirmation this._id, (id)->
      Session.set "category_id", Categories.findOne()._id
      Meteor.call "removeCategory", id

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
  selected: ->
    if Session.equals("category_id", this._id) then "active" else ""
