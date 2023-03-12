import regex
import std/[os, strformat, strutils, times]
import tables

type
  Track = object
    start: Duration
    duration: Duration
    name: string

proc panic(errorCode: int, text: string) {.noreturn.} =
  echo text
  quit(errorCode)

const timeRegex = re"(?:(?P<hours>\d{1,2})(?::))?(?P<minutes>\d{1,2}):(?P<seconds>\d{1,2})"
proc parseTotalDuration(text: string): Duration =
  var hours, minutes, seconds: uint
  var m: RegexMatch
  if match(text, timeRegex, m):
    hours = parseUint(m.group(m.namedGroups["hours"], text)[0])
    minutes = parseUint(m.group(m.namedGroups["minutes"], text)[0])
    seconds = parseUint(m.group(m.namedGroups["seconds"], text)[0])
  else:
    panic(2, "Invalid syntax in 'total track time' argument.")

  times.initDuration(hours = int(hours), minutes = int(minutes), seconds = int(seconds))

const trackRegex = re"(?:(?P<hours>\d{1,2})(?::))?(?P<minutes>\d{1,2}):(?P<seconds>\d{1,2})\s(?P<track>.*)"
proc parseTrack(lineNumber: uint, trackText: string): Track =
  var hours, minutes, seconds: uint
  var trackName: string
  var m: RegexMatch
  if match(trackText, trackRegex, m):
    hours = if m.groupFirstCapture("hours", trackText) != "": parseUint(m.groupFirstCapture(m.namedGroups["hours"], trackText)) else: 0
    minutes = if m.groupFirstCapture("minutes", trackText) != "": parseUint(m.groupFirstCapture(m.namedGroups["minutes"], trackText)) else: 0
    seconds = if m.groupFirstCapture("seconds", trackText) != "": parseUint(m.groupFirstCapture(m.namedGroups["seconds"], trackText)) else: 0
    trackName = m.group(m.namedGroups["track"], trackText)[0]
  else:
    panic(4, fmt"Syntax error in input file, line {lineNumber}")

  Track(
    start: times.initDuration(hours = int(hours), minutes = int(minutes), seconds = int(seconds)),
    duration: times.initDuration(),
    name: trackName
  )



if paramCount() != 2:
  panic(1, fmt"Invalid syntax. Usage: {paramStr(0)} [input file name] [total track time (?(hh):mm:ss)]")

let totalDuration = parseTotalDuration(paramStr(2))
let inputFilePath = paramStr(1)
var contents: string
try:
  contents = readFile(inputFilePath)
except IOError:
  panic(3, fmt"Unable to read file '{inputFilePath}'.")


var entries = newSeq[Track]()
for i, line in pairs(contents.split("\n")):
  let lineNumber = i + 1
  var track = parseTrack(uint(lineNumber), line)
  entries.add(track)

  if entries.len() > 1:
    var previousTrack = addr(entries[^2])
    previousTrack.duration = track.start - previousTrack.start

var metadataOutput: string
metadataOutput.add(";FFMETADATA1\n")
for i, entry in pairs(entries):
  metadataOutput.add("[CHAPTER]\n")
  metadataOutput.add("TIMEBASE=1/1\n")
  metadataOutput.add(&"START={entry.start.inSeconds()}\n")
  
  # If we're at the final track, then we need to use the total time, specified by the user
  let isFinalTrack = i == entries.len() - 1
  let endDuration = if isFinalTrack: totalDuration else: entry.start + entry.duration
  metadataOutput.add(&"END={endDuration.inSeconds()}\n")
  metadataOutput.add(&"title={entry.name}")
  if not isFinalTrack:
    metadataOutput.add("\n\n")

try:
  writeFile("metadata.txt", metadataOutput)
except IOError:
  panic(5, "Unable to write metadata file.")