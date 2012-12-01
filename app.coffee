arDrone = require("ar-drone")
opencv = require("opencv")

client = arDrone.createClient()
client.takeoff()
client.after(5000, ->
  @clockwise 0.5
).after(3000, ->
  @animate "flipLeft", 15
).after 1000, ->
  @stop()
  @land()


# Camera stream
pngStream = arDrone.createPngStream()

