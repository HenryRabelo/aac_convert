#!/bin/bash
# Custom ffmpeg package downloaded from Jellyfin:
# https://github.com/jellyfin/jellyfin-ffmpeg

Help() {
echo "
Advanced Audio Codec Batch Converter script.

Summary:
 This script was made to simplify converting audio files
 downloaded from stores such as Bandcamp to the AAC codec.

Syntax:
 aac-convert COMMAND [OPTIONS]
 
Commands:
 --help				Print this Help page.
 
 --batch INPUT OUTPUT		Batch convert files from a directory
 				to another directory.

 --file INPUT			Convert a single file.
"
}

ResolveCommands() {
  if [ "$1" == '--help' ]; then
    Help
    exit 0
  elif [ "$1" == '--batch' ]; then
    if [ "$2" -ef "$HOME" ]; then
      echo 'Error: Input directory can not be the home directory due to the'
      echo 'hidden configuration files present.'
      echo 'Please choose a dedicated directory for the input path.'
      exit 1
    elif ! [ -d "$2" ]; then
      echo 'Error: Input directory not found.'
      echo 'Pass the input path as an argument.'
      exit 1
    elif ! [ -d "$3" ]; then
      echo 'Error: Output directory not found.'
      echo 'Pass the output path as an argument.'
      exit 1
    fi
    Batch "$2" "$3"
    exit 0
  elif [ "$1" == '--file' ]; then
    if ! [ -f "$2" ]; then
      echo 'Error: File not found in this directory.'
      echo 'Please pass the file as an argument.'
      exit 1
    fi
    Convert "$2"
    exit 0
  else
    Help
    exit 1
  fi
}

Batch() {
  INPUT=$(find "$1" -type d)
  OUTPUT="$2"

  # Set IFS (Internal Field Separator) exclusively to newlines during "for" loop
  IFS=$'\n'
  for DIRECTORY in $INPUT; do
    mkdir -p "$OUTPUT/$DIRECTORY"
    FILES=$(find "$DIRECTORY" -maxdepth 1 -type f)
    
    for MUSIC in $FILES; do
      TYPE=$(file $MUSIC | grep --only-matching "image|text" | head -1)
      
      # Skip conversion for cover image files
      if [ "$TYPE" == 'image' || "$TYPE" == 'text' ]; then
        continue
      fi
      
      Convert "$MUSIC" "$OUTPUT/"
    done
  
  done
  unset IFS
  # Reset (unset) IFS
  
  exit 0
}

Convert() {
  # Get filename without extension
  FILENAME=$(echo "$1" | sed -e 's/\.[^./]*$//')
  CONVERT="${2}$FILENAME"
  
  ffmpeg -i "$1" -c:a libfdk_aac -afterburner 1 -cutoff 20000 -ar 44100 -vbr 5 -c:v png -vf scale=600:600:force_original_aspect_ratio=decrease "$CONVERT".m4a
}

ResolveCommands "$@"

