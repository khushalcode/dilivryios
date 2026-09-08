importScripts("https://www.gstatic.com/firebasejs/7.20.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/7.20.0/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyAB9vbYCP6lzVR5fX6c4-JBEBOfP81XDGk",
  authDomain: "talabego.firebaseapp.com",
  projectId: "talabego",
  storageBucket: "talabego.firebasestorage.app",
  messagingSenderId: "924347123755",
  appId: "1:924347123755:web:4c45e2c0206f0a7dfb826e"
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});