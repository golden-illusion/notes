Notes = new Mongo.Collection("notes");

Meteor.subscribe("notes");

Session.setDefault("editing_note", null)


//temlates
Template.noteList.helpers({
  notes: function(){
    return Notes.find({}).fetch();
  }
});

Template.noteForm.events({
  "click #create-note": function(e){
    Meteor.call("create", $(Template.instance).find("#note-form").val())
  }
});

Template.noteItem.events({
  "click .remove": function(){
    Meteor.call("remove", this._id)
  },
  "dblclick .note-content": function(){
    Session.set("editing_note", this._id)
  }
})

Template.noteItem.events(okCancelEvents(
  ".input-content",
  {
    ok: function(content, event){
      Session.set("editing_note", null)
      Meteor.call("update", this._id, content)
    }
  }
));

Template.noteItem.editing = function(){
  return Session.equals("editing_note", this._id)
}

