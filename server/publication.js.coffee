Notes = new Mongo.Collection "notes"
Categories = new Mongo.Collection "categories"

Meteor.publish "categories", (userId) ->
  Categories.find({userId: userId})

Meteor.publish "notes", (category_id, userId)->
  Notes.find({category_id: category_id, userId: userId})

Meteor.methods
  createNote: (content, category_id) ->
    if this.userId isnt null
      Notes.insert({userId: this.userId, content: content, category_id: category_id})
    else
      throw new Meteor.Error(userId)
  removeNote: (query) ->
    if this.userId isnt null
      Notes.remove(query)
    else
      throw new Meteor.Error(userId)
  updateNote: (selector, query, options) ->
    if this.userId isnt null
      Notes.update(selector, query, options)
    else
      throw new Meteor.Error(userId)
  createCategory: (title) ->
    if this.userId isnt null
      Categories.insert {title: title, userId: this.userId}
    else
      throw new Meteor.Error userId
  removeCategory: (category_id) ->
    if this.userId isnt null
      Notes.remove {category_id: category_id}
      Categories.remove {_id: category_id}
    else
      throw new Meteor.Error this.userId
  updateCategory: (selector, query, options) ->
    if this.userId isnt null
      Categories.update(selector, query, options)
    else
      throw new Meteor.Error(userId)