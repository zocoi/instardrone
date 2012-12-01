require("coffee-script");

var sys = require('sys'),
    http = require('http'),
    ws = require("./utils/ws")


// Command line args
var username = "twitdron1"
var password = "thedrone";
var keyword = "apple";


var Twit = require('twit')

var T = new Twit({
    consumer_key:         '4kygiZAnk74lz0apFQA'
  , consumer_secret:      'UQhTU1MjgT7fTAQprFBl9Z0EVtzYAnLUNYvMugEHRHg'
  , access_token:         '983003724-8Unflf2U7c3IF3fNID6hvPaOidwwqjmnFk2XDC98'
  , access_token_secret:  'Uqh3uOGV9gRRFIoJuCdBgmGR1d2w7Tc9ZzcMlKa1tA'
})

var stream = T.stream('statuses/filter', { track: '@FaceDrone' })

stream.on('tweet', function (tweet) {
  console.log(clients.length)
  for(var i=0; i<clients.length; i++) {
    console.log("Emitting")
    clients[i].emit("tweet", tweet.text);
  }
})

clients = [];

var io = require('socket.io').listen(9090);

io.sockets.on('connection', function (socket) {
  console.log("......................")
  clients.push(socket);
});

var express = require('express')
  , http = require('http')
  , path = require('path');

var app = express();

app.configure(function(){
  app.set('port', process.env.PORT || 3000);
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.favicon());
  app.use(express.logger('dev'));
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);
  app.use(express.static(path.join(__dirname, 'public')));
});

app.configure('development', function(){
  app.use(express.errorHandler());
});

app.get('/', require('./routes/index'));
app.get('/what', require('./routes/index'));

http.createServer(app).listen(8080, function(){
  console.log("Express server listening on port 8080")
});
