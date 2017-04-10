// pull in desired CSS/SASS files
require('./styles/main.scss');

// inject bundled Elm app into div#main
var Elm = require('../elm/Main');
var elmApp = Elm.Main.embed(document.getElementById('main'));

// Initialize Firebase
var config = {
  apiKey: 'AIzaSyCLfwCRlTMjo9hC657W3c65jnm5HMRQA7w',
  authDomain: 'myevents-dc4e5.firebaseapp.com',
  databaseURL: 'https://myevents-dc4e5.firebaseio.com',
  projectId: 'myevents-dc4e5',
  storageBucket: 'myevents-dc4e5.appspot.com',
  messagingSenderId: '134196672178',
};

var app = firebase.initializeApp(config);
var database = app.database();
var EVENTS_PATH = 'events';

function addEvent(event) {
  var promise = database.ref(EVENTS_PATH).push(event);
  return promise;
}

function updateEvent(event) {
  var id = event.id;
  var promise = database.ref(EVENTS_PATH + '/' + id).set(event);
  return promise;
}

function deleteEvent(event) {
  var id = event.id;
  var promise = database.ref(EVENTS_PATH + '/' + id).remove();
  return promise;
}

function eventsListener() {
  return database.ref(EVENTS_PATH).orderByChild('datetime');
}

var listener = eventsListener();
listener.on('child_added', function(data) {
  var event = Object.assign(data.val(), {id: data.key});
  elmApp.ports.newEvent.send(event);
});

elmApp.ports.addEvent.subscribe(function(event) {
  addEvent(event).then(
    function(response) {
      elmApp.ports.eventSaved.send(response.key);
    },
    function(err) {
      console.log('error:', err);
    }
  );
});

elmApp.ports.editEvent.subscribe(function(event) {
  updateEvent(event).then(
    function() {
      elmApp.ports.eventSaved.send(event.id);
    },
    function(err) {
      console.log('error:', err);
    }
  );
});

elmApp.ports.removeEvent.subscribe(function(event) {
  deleteEvent(event);
});
