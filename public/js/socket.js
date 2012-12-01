$(document).ready(function(){
  index = 0;
  var socket = io.connect('http://localhost:9090');
  socket.on('tweet', function (data) {


    var tweet = $("<div class='tweet' style='display:none'><div class='content'>" + data + "</div></div>");
    if (data.indexOf("http://") == 0) {
      tweet = $("<div class='tweet' style='display:none'><div class='content'><img width='320' height='240' src='" + data + "' /></div></div>");
    }

    var p
    if(index % 3 == 0) {
      p = $("<p style='display:none; height:230px;'></p>");
      $('#tweets').prepend(p);
      p.slideDown(400);
    } else {
      p = $('#tweets p:first');
    }
    index++
    p.append(tweet);
    tweet.show(400);

    if($('#tweets p').size() > 30) {
      $('#tweets p:last').remove();
    }

  });

});