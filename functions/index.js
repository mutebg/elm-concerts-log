var functions = require("firebase-functions");

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

exports.makeUppercase = functions.database
  .ref("/events/{userId}/{event}")
  .onWrite(event => {
    const data = event.data.val();
    console.log(data);
    return event;
  });
