# ffmpeg-track-metadata-generator
This small tool generates FFMETADATA based on a list of tracks. How does this work? See the following example!

Suppose you have 'tracklist.txt', with the following content:
>00:00 Artist 1 - Track 1\
>01:01 Artist 1 - Track 2\
>02:22 Artist 2 - Track 1

And you want to use this tracklist for use in some audio file. Well... you can make the FFMETADATA file by hand (which is tedious), or use this tool to generate it for you.\
\
Usage: `ffmpeg-track-metadata-generator [input file name] [total track time (?(hh):mm:ss)]`\
\
The resulting **metadata.txt** is going to look like this:
>;FFMETADATA1\
>[CHAPTER]\
>TIMEBASE=1/1\
>START=0\
>END=61\
>title=Artist 1 - Track 1\
>\
>[CHAPTER]\
>TIMEBASE=1/1\
>START=61\
>END=142\
>title=Artist 1 - Track 2\
>\
>[CHAPTER]\
>TIMEBASE=1/1\
>START=142\
>END=[end time of the final track (total track time parameter)]\
>title=Artist 2 - Track 1

You can then use the generated **metadata.txt** like this: `ffmpeg -i [input file] -f ffmetadata -i metadata.txt -map_metadata 1 -c copy [output file]`

For more info on the metadata format for ffmpeg, visit https://ffmpeg.org/ffmpeg-formats.html
