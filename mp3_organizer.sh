#!/bin/bash

# Prompt user for YouTube playlist link
echo "Enter YouTube playlist link:"
read link

# Install necessary packages if they are not already installed
sudo apt-get install youtube-dl ffmpeg id3v2 -y

# Download videos as .mp3 files
youtube-dl --extract-audio --audio-format mp3 $link

# Loop through all .mp3 files in the current directory
for file in *.mp3; do
  # Get video title from file name
  title=$(echo $file | cut -f 1 -d '.')

  # Use youtube-dl to get video metadata
  metadata=$(youtube-dl --skip-download --get-title --get-id $link)
  title=$(echo "$metadata" | awk 'NR==1')
  video_id=$(echo "$metadata" | awk 'NR==2')

  # Use youtube-dl to get video thumbnail
  thumbnail_url=$(youtube-dl --skip-download --get-thumbnail $link)

  # Use youtube-dl to get video artist name
  artist=$(youtube-dl --skip-download --get-artist $link)

  # Use youtube-dl to get video album name
  album=$(youtube-dl --skip-download --get-album $link)

  # Use ffmpeg to add thumbnail as cover art
  ffmpeg -i $file -i $thumbnail_url -map 0:0 -map 1:0 -c copy -id3v2_version 3 -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (Front)" cover.jpg
  ffmpeg -i $file -i cover.jpg -map 0:0 -map 1:0 -c copy -id3v2_version 3 -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (Front)" $file

  # Use id3v2 to add title, artist, and album name to file
  id3v2 -a "$artist" -A "$album" -t "$title" $file

done

# Create a folder for each artist and move files into respective folders
for artist in $(ls -l | awk '{print $9}' | awk -F '-' '{print $1}' | sort -u); do
    mkdir "$artist"
    mv *"$artist"*.mp3 "$artist"/
done
