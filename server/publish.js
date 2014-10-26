Notes = new Mongo.Collection("notes");

Meteor.publish("notes", function(){
    return Notes.find({});
})

Meteor.methods({
  "create": function(content){
    if (this.userId !== null)
      Notes.insert({userId: this.userId, content: content})
    else
      throw new Meteor.Error(userId);
  },
  "remove": function(id){
    if (this.userId !== null)
      Notes.remove({_id: id})
    else
      throw new Meteor.Error(userId);
  },
  "update": function(id, content){
    if (this.userId !== null)
      Notes.update(id, {$set: {content: content}});
    else
      throw new Meteor.Error(userId);
  }
});
