Notes = new Mongo.Collection("notes");

Meteor.subscribe("notes");

Session.setDefault("editing_note", null)

//helpers
var okCancelEvents = function (selector, callbacks) {
  var ok = callbacks.ok || function () {};
  var cancel = callbacks.cancel || function () {};

  var events = {};
  events['keyup '+ selector + ', keydown ' + selector + ', focusout ' +selector] =
    function (evt) {
      if (evt.type === "keydown" && evt.which === 27) {
        cancel.call(this, evt);
      }
      else if (evt.type === "keyup" && evt.which === 13 || evt.type === "focusout") {
        var value = String(evt.target.value || "");
        if (value)
          ok.call(this, value, evt);
        else
          cancel.call(this, evt);
      }
    };
  return events;
};

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

