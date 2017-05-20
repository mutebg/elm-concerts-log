// pull in desired CSS/SASS files
require("./styles/main.scss");

// inject bundled Elm app into div#main
var Elm = require("../elm/Main");
var elmApp = Elm.Main.embed(document.getElementById("main"));

// Initialize Firebase
var config = {
  apiKey: "AIzaSyCLfwCRlTMjo9hC657W3c65jnm5HMRQA7w",
  authDomain: "myevents-dc4e5.firebaseapp.com",
  databaseURL: "https://myevents-dc4e5.firebaseio.com",
  projectId: "myevents-dc4e5",
  storageBucket: "myevents-dc4e5.appspot.com",
  messagingSenderId: "134196672178"
};

var app = firebase.initializeApp(config);
var database = app.database();
var EVENTS_PATH = "events";

initApp();

// https://raw.githubusercontent.com/firebase/quickstart-js/master/auth/google-popup.html
function toggleSignIn() {
  if (!firebase.auth().currentUser) {
    var provider = new firebase.auth.GoogleAuthProvider();
    firebase
      .auth()
      .signInWithPopup(provider)
      .then(result => {
        var token = result.credential.accessToken;
        var user = result.user;
        signIn(user);
        loadItems();
      })
      .catch(error => {});
  } else {
    signOut();
    firebase.auth().signOut();
  }
}

function initApp() {
  firebase.auth().onAuthStateChanged(user => {
    if (user) {
      signIn(user);
      eventsListener();
    } else {
      signOut();
    }
  });
}

function signIn(rowUser) {
  const user = {
    name: rowUser.displayName,
    avatar: rowUser.photoURL
  };
  elmApp.ports.signIn.send(user);
}

function signOut() {
  console.log("signOut");
  elmApp.ports.signOut.send("none");
}

const eventsPath = () =>
  "events/" +
  (firebase.auth().currentUser ? firebase.auth().currentUser.uid : 0);

function addEvent(event) {
  var promise = database.ref(eventsPath()).push(event);
  return promise;
}

function updateEvent(event) {
  var id = event.id;
  var promise = database.ref(eventsPath() + "/" + id).set(event);
  return promise;
}

function deleteEvent(event) {
  var id = event.id;
  var promise = database.ref(eventsPath() + "/" + id).remove();
  return promise;
}

function eventsListener() {
  var listener = database.ref(eventsPath()).orderByChild("datetime");
  listener.on("child_added", function(data) {
    var event = Object.assign(data.val(), { id: data.key });
    elmApp.ports.newEvent.send(event);
  });
}

elmApp.ports.addEvent.subscribe(function(event) {
  addEvent(event).then(
    function(response) {
      elmApp.ports.eventSaved.send(response.key);
    },
    function(err) {
      console.log("error:", err);
    }
  );
});

elmApp.ports.editEvent.subscribe(function(event) {
  updateEvent(event).then(
    function() {
      elmApp.ports.eventSaved.send(event.id);
    },
    function(err) {
      console.log("error:", err);
    }
  );
});

elmApp.ports.removeEvent.subscribe(function(event) {
  deleteEvent(event);
});

// SIGN IN / SIGN OUT
elmApp.ports.toggleSignIn.subscribe(() => {
  toggleSignIn();
});
