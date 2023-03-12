# Package

version       = "1.0.0"
author        = "darkcharmander"
description   = "This small tool generates FFMETADATA based on a list of tracks."
license       = "MIT"
srcDir        = "src"
bin           = @["ffmpeg_track_metadata_generator"]


# Dependencies

requires "nim >= 1.6.10", "regex >= 0.20.1"
