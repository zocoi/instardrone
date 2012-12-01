arDrone = require("ar-drone")
cv = require("opencv")
http = require("http")


client = arDrone.createClient()
# client.takeoff()
# client.after(5000, ->
#   @clockwise 0.5
# ).after 10000, ->
#   @stop()
#   @land()

# client.land()
# return


# Camera stream
pngStream = arDrone.createPngStream()
lastPng = null
lastFacePng = null
faceCascade = new cv.CascadeClassifier('node_modules/opencv/data/haarcascade_frontalface_alt2.xml')

processingImage = false

pngStream
  .on('error', console.log)
  .on 'data', (pngBuffer) ->
    # console.log("got image")
    lastPng = pngBuffer

camera_started = false
client.on 'navdata', (data) =>
  # console.log data

  if data.droneState.cameraReady
    faceDetection()

    unless camera_started
      startFlight()

      camera_started = true

  if data.droneState.lowBattery
    console.log "Low battery"
    client.stop()
    client.land()

startFlight = =>
  client.takeoff()

  client.after 2000, ->
    @stop()
    @up(1.0)
    @clockwise(0.5)

  client.after 4000, ->
    @stop()

  client.after 10000, ->
    @stop()
    @land()

faceDetection = ->
  return unless lastPng
  console.log "Processing Image..."
  processingImage = true
  cv.readImage lastPng, (err, im)->
    faceCascade.detectMultiScale im, (err, matrices)->
      return if matrices.length == 0
      if matrices.length == 1
        matrix = matrices[0]
      else
        # Got many face matrices, only get the biggest one
        matrix = matrices.reduce (a,b) -> if a.width >= b.width then a else b
      # Draw a circle on his freaking face
      im.ellipse(matrix.x + matrix.width/2, matrix.y + matrix.height/2, matrix.width/2, matrix.height/2)
      
      lastFacePng = im.toBuffer()
      console.log "Found a face: ", lastFacePng
      # Finish
      processingImage = false

client.createRepl()


# Show the face image
server = http.createServer (req, res)->
  if (!lastFacePng)
    res.writeHead(503)
    res.end('Did not receive any png data yet.')
    return

  res.writeHead(200, {'Content-Type': 'image/png'})
  res.end(lastFacePng)


server.listen 8080, ()->
  console.log('Serving latest png on port 8080 ...')

