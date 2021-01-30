#!/bin/bash
for file in /vids/*.mp4
do
	fn=$(echo $file | cut -f 1 -d '.')
    	ffmpeg -y -i $file -c copy $fn.mkv
done
