#!/bin/sh
inotifywait -m --exclude "[^mp4]$" /vids -e close_write |
    while read path action file; do
        echo "The file '$file' appeared in directory '$path' via '$action'"
        fn=$(echo $file | cut -f 1 -d '.')
        echo "The filename is '$fn'"
        ffmpeg -y -i "$path$file" -c copy "$path$fn.mkv"
        rm "$path$file"
done
