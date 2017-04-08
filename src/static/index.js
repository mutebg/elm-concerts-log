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
  return database.ref(EVENTS_PATH);
}

var listener = eventsListener();
listener.on('child_added', function(data) {
  var event = Object.assign(data.val(), {id: data.key});
  elmApp.ports.newEvent.send(event);
});

elmApp.ports.addEvent.subscribe(event => {
  addEvent(event).then(
    response => {
      elmApp.ports.eventSaved.send(response.key);
    },
    err => {
      console.log('error:', err);
    }
  );
});

elmApp.ports.editEvent.subscribe(event => {
  updateEvent(event).then(
    () => {
      elmApp.ports.eventSaved.send(event.id);
    },
    err => {
      console.log('error:', err);
    }
  );
});

elmApp.ports.removeEvent.subscribe(event => {
  deleteEvent(event).then(
    () => {
      //elmApp.ports.eventSaved.send(event.id);
    },
    err => {
      console.log('error:', err);
    }
  );
});
