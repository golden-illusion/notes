Notes = new Mongo.Collection("notes");

Meteor.subscribe("notes");

Session.setDefault("editing_note", null)
Session.setDefault("inserting_note", null)

//temlates
Template.noteList.helpers({
  notes: function(){
    return Notes.find({}).fetch();
  }
});

Template.noteForm.events({
  "click #create-note": function(e, template){
    Session.set("inserting_note", this._id)
    Tracker.flush()
    template.find("#input-content").focus()
    template.find("#input-content").select()
  }
});

Template.noteItem.events({
  "click .remove": function(){
    Meteor.call("remove", this._id)
  },
  "dblclick .note-content": function(event, template){
    Session.set("editing_note", this._id)
    Tracker.flush()
    template.find("#input-content").focus()
    template.find("#input-content").select()
  }
})

Template.noteItem.events(okCancelEvents(
  "#input-content",
  {
    ok: function(content, event){
      Session.set("editing_note", null)
      Meteor.call("update", this._id, content)
    },
    cancel: function(){
      Session.set("editing_note", null)
    }
  }
));

Template.noteForm.events(okCancelEvents(
  "#input-content",
  {
    ok: function(content, event){
      Session.set("inserting_note", null)
      Meteor.call("create", content)
    },
    cancel: function(){
      Session.set("editing_note", null)
    }
  }
));

Template.noteItem.editing = function(){
  return Session.equals("editing_note", this._id)
}

Template.noteForm.inserting = function(){
  return Session.equals("inserting_note", this._id)
}

Template.noteItem.content = function(){
  return Autolinker.link(this.content)
}