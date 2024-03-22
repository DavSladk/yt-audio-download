#!/bin/bash

# Check if youtube-dl is installed
if ! command -v youtube-dl &> /dev/null; then
  echo "youtube-dl is not installed. Please install it first."
  exit 1
fi

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
  echo "ffmpeg is not installed. Please install it first."
  exit 1
fi

# Check if metaflac is installed
if ! command -v metaflac &> /dev/null; then
  echo "flac is not installed. Please install it first."
  exit 1
fi

# Check if one argument is provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <url>"
  exit 1
fi

# Download the audio and thumbnail
youtube-dl -x --audio-format best --audio-quality 0 --write-thumbnail -o 'tmp-%(title)s.$(ext)s' $1

# get the audio file that starts with tmp- and end with audio extension
audio_file=$(ls | grep -E 'tmp-.*\.(mp3|webm|wav|flac|ogg|aac|wma|opus|m4a)')
# get the thumbnail file that starts with tmp- and end with image extension
thumbnail_file=$(ls | grep -E 'tmp-.*\.(jpg|png|jpeg|webp)')

# cut the extension from the audio file
audio_file_no_ext="${audio_file%.*}"
# cut tmp- from the audio file
audio_file_no_tmp="${audio_file_no_ext#tmp-}"
# add flac extension to the audio file
audio_file_flac=$audio_file_no_tmp.flac

#check if thumnail file has .webp extension
if [ "${thumbnail_file##*.}" = "webp" ]; then
  # convert the webp thumbnail to jpg
  thumbnail_file_jpg="${thumbnail_file%.*}.jpg"
  ffmpeg -i "$thumbnail_file" "$thumbnail_file_jpg"
  thumbnail_file=$thumbnail_file_jpg
fi

# convert the audio file to flac and embed the thumbnail
ffmpeg -i "$audio_file" -c:a flac "$audio_file_flac"
metaflac --import-picture-from="$thumbnail_file" "$audio_file_flac"

# clean up
rm "$audio_file" "$thumbnail_file"