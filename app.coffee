arDrone = require("ar-drone")
cv = require("opencv")

client = arDrone.createClient()
client.takeoff()
client.after(5000, ->
  @clockwise 0.5
).after 1000, ->
  @stop()
  @land()


# Camera stream
pngStream = arDrone.createPngStream()
lastPng = null
face_cascade = new cv.CascadeClassifier('node_modules/opencv/data/haarcascade_frontalface_alt2.xml');

processingImage = false

pngStream
  .on('error', console.log)
  .on('data', (pngBuffer) ->
    console.log("got image")
    lastPng = pngBuffer
    
faceDetection = ->
  processingImage = true
  cv.readImage(lastPng, (err, im)->
    face_cascade.detectMultiScale im, (err, faces)->
      for face in faces
        im.ellipse(face.x + face.width/2, face.y + face.height/2, face.width/2, face.height/2);
      buff = im.toBuffer()
      # Finish
      processingImage = false

client.createRepl()
