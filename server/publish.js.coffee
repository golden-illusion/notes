Notes = new Mongo.Collection "notes"
Categories = new Mongo.Collection "categories"

Meteor.publish "categories", ->
  Categories.find({})

Meteor.publish "notes", (category_id)->
  Notes.find({category_id: category_id})

Meteor.methods
  createNote: (content, category_id) ->
    if this.userId isnt null
      Notes.insert({userId: this.userId, content: content, category_id: category_id})
    else
      throw new Meteor.Error(userId)
  removeNote: (id) ->
    if this.userId isnt null
      Notes.remove({_id: id})
    else
      throw new Meteor.Error(userId)
  updateNote: (id, content) ->
    if this.userId isnt null
      Notes.update(id, {$set: {content: content}})
    else
      throw new Meteor.Error(userId)
  createCategory: (title) ->
    if this.userId isnt null
      Categories.insert {title: title}
    else
      throw new Meteor.Error userId
  removeCategory: (category_id) ->
    if this.userId isnt null
      Notes.remove {category_id: category_id}
      Categories.remove {_id: category_id}
    else
      throw new Meteor.Error this.userId