arDrone = require("ar-drone")
cv = require("opencv")
http = require("http")
client = arDrone.createClient()


# Camera stream
pngStream = arDrone.createPngStream()
lastPng = null
lastFacePng = null
faceCascade = new cv.CascadeClassifier('node_modules/opencv/data/haarcascade_frontalface_alt2.xml')
noseCascade = new cv.CascadeClassifier('node_modules/opencv/data/haarcascade_mcs_nose.xml')
processingImage = false
current_x = 0;
current_y = 0;
current_width = 0;

face_max_width = 3/4 * 554
image_center_x = 554/2
image_center_y = 312/2

reset_values = =>
  face_max_width = 3/4 * 554
  image_center_x = 554/2
  image_center_y = 312/2

flight_loop_start = false

pngStream
  .on('error', console.log)
  .on 'data', (pngBuffer) ->
    # console.log("got image")
    lastPng = pngBuffer

camera_started = false
client.on 'navdata', (data) =>
  # console.log data
  #console.log "x " + current_x + " y " + current_y

  if data.droneState.cameraReady
    faceDetection()

    unless camera_started
      startFlight()

      camera_started = true

    if (flight_loop_start)
      flight_loop()

  if data.droneState.lowBattery
    console.log "Low battery"
    client.land()

moving_left = false;
moving_up = false;
moving_right = false;
moving_down = false;

flight_loop = =>
  return
  # if current_x < image_center_x
  #   if (moving_right)
  #     client.stop()
  #     moving_right = false
  #   if (!moving_left)
  #     console.log "moving left"
  #     moving_left = true
  #     client.counterClockwise(0.1)
    
  # if current_x > image_center_x
  #   if (moving_left)
  #     client.stop()
  #     moving_left = false
  #   if (!moving_right)
  #     console.log "moving right"
  #     moving_right = true
  #     client.clockwise(0.1)

  # # if (current_width < face_max_width)
  # #   console.log "front"
  # #   client.front(0.1)
  # # else
  # #   console.log "back"
  # #   client.back(0.1)

startFlight = =>
  client.takeoff()
  client.after(10000, ->
    client.up 1.0
  ).after(5000, ->
    client.stop()
  ).after(5000, ->
    flight_loop_start = true
  )

animating = false

faceDetection = =>
  # return unless lastPng
  # console.log "Processing Image..."
  processingImage = true
  cv.readImage "jyri.png", (err, im)=>
    noseCascade.detectMultiScale im, (err, matrices)=>
      return if err
      if matrices.length == 0 
        reset_values()
        return
      if matrices.length == 1
        matrix = matrices[0]
      else
        # Got many matrices, only get the biggest one
        matrix = matrices.reduce (a,b) -> if a.width >= b.width then a else b
        
      console.log "face matrix: ", matrix
      # Draw a circle on his freaking face
      im.ellipse(matrix.x + matrix.width/2, matrix.y + matrix.height/2, matrix.width/2, matrix.height/2)
      current_width = matrix.width
      current_x = matrix.x
      current_y = matrix.y

      # Draw a moustache below his nose
      cv.readImage "moustache.png", (err, moustache)->
        imMatrix = new cv.Matrix(im.width(), im.height())
        imMatrix.addWeighted(im, 0.7, moustache, 0.9)
        imMatrix.toBuffer()

      
      lastFacePng = im.toBuffer()

      # if (!animating)
      #   animating = YES
      #   client.animate('flipLeft', 15);

      # console.log "Found a face: ", lastFacePng
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

