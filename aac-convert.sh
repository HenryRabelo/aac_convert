#!/bin/bash

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
  if [ -z $(ffmpeg -loglevel 'quiet' -codecs | grep --only-matching 'libfdk_aac' | head -1) ]; then
    echo 'Error: Your build of FFMPEG has not enabled the libfdk_aac codec.'
    exit 1
  elif [ "$1" = '--help' ]; then
    Help
    exit 0
  elif [ "$1" = '--file' ]; then
    if [ ! -f "$2" ]; then
      echo 'Error: File not found in this directory.'
      echo 'Please pass the file as an argument.'
      exit 1
    fi
    Convert "$2"
    exit 0
  elif [ "$1" = '--batch' ]; then
    if [ "$2" -ef "$HOME" ]; then
      echo 'Error: Input directory can not be the home directory due to the'
      echo 'hidden configuration files present.'
      echo 'Please choose a dedicated directory for the input path.'
      exit 1
    elif [ ! -d "$2" ]; then
      echo 'Error: Input directory not found.'
      echo 'Please create or pass a valid input path as an argument.'
      exit 1
    elif [ ! -d "$3" ]; then
      echo 'Error: Output directory not found.'
      echo 'Please create or pass a valid output path as an argument.'
      exit 1
    fi
    Batch "$2" "$3"
    exit 0
  else
    Help
    exit 1
  fi
}

BuildTags() {
  TAG=''
  local CUSTOM=''
  local DOMAIN='domain="com.apple.iTunes"'
  local TOTALTRACKS=$(echo "$1" | grep 'totaltracks' | cut -d'=' -f2-)
  local TOTALDISCS=$(echo "$1" | grep 'totaldiscs' | cut -d'=' -f2-)
  
  IFS=$'\n'
  for DATA in $1; do
    local TAGNAME=$(echo "$DATA" | cut -d'=' -f1)
    local VALUE=$(echo "$DATA" | cut -d'=' -f2-)
    
    # Skip if data somehow has no assigned value
    if [ -z "$VALUE" ]; then
      continue
    elif [ "$TAGNAME" = 'musicbrainz_albumid' ]; then
      CUSTOM='true'
    elif [ "$TAGNAME" = 'releasecountry' ]; then
      CUSTOM='true'
    elif [ "$TAGNAME" = 'releasetype' ]; then
      CUSTOM='true'
    elif [ "$TAGNAME" = 'label' ]; then
      CUSTOM='true'
    elif [ "$TAGNAME" = 'replaygain_track_gain' ]; then
      CUSTOM='true'
    elif [ "$TAGNAME" = 'replaygain_album_gain' ]; then
      CUSTOM='true'
    elif [ "$TAGNAME" = 'replaygain_track_peak' ]; then
      CUSTOM='true'
    elif [ "$TAGNAME" = 'replaygain_album_peak' ]; then
      CUSTOM='true'
    elif [ "$TAGNAME" = 'bpm' ]; then
      CUSTOM='false'
    elif [ "$TAGNAME" = 'track' ]; then
      CUSTOM='false'
      if [ ! -z "$TOTALTRACKS" ]; then
        VALUE="$VALUE/$TOTALTRACKS"
      fi
    elif [ "$TAGNAME" = 'disc' ]; then
      TAGNAME='disk'
      CUSTOM='false'
      if [ ! -z "$TOTALDISCS" ]; then
        VALUE="$VALUE/$TOTALDISCS"
      fi
    else
      # Skip if data is not found on list
      continue
    fi
    
    # Add to return tag on each iteration
    if [ "$CUSTOM" = 'false' ]; then
      TAG=$(echo "$TAG" "--$TAGNAME" "\"$VALUE\"")
    else
      TAG=$(echo "$TAG" '--rDNSatom' "\"$VALUE\"" "name=\"$TAGNAME\"" "$DOMAIN")
    fi
  done
  unset IFS
  unset CUSTOM
  
  # Print finished tag as a means of returning the value
  echo "$TAG"
}

Batch() {
  local INDICATOR=1
  local TOTALFILES=$(find "$1" -type f | grep --invert-match '.jpg\|.png\|.txt\|.lrc\|.m3u' | wc -l)
  local INPUT=$(find "$1" -type d)
  local OUTPUT="$2"

  # Set IFS (Internal Field Separator) exclusively to newlines during "for" loop
  IFS=$'\n'
  for DIRECTORY in $INPUT; do
    mkdir -p "$OUTPUT/$DIRECTORY"
    FILES=$(find "$DIRECTORY" -maxdepth 1 -type f)
    
    # Skip cycle for directories with no files
    if [ -z "$FILES" ]; then
      continue
    fi
    
    echo 'Entering' $(basename "$DIRECTORY")
    echo ''
    
    for MUSIC in $FILES; do
      TYPE=$(file "$MUSIC" | grep --only-matching "image\|text" | head -1)
      
      # Skip conversion for cover image files or lyric files
      if [ "$TYPE" = 'image' -o "$TYPE" = 'text' ]; then
        continue
      fi
      
      local PERCENTAGE=$(echo "scale=2; ($INDICATOR * 100 / $TOTALFILES)" | bc)
      local FILESREM=$(( TOTALFILES - INDICATOR ))
      local TIMEREM=$(( (($SECONDS * $TOTALFILES) / $INDICATOR) - $SECONDS ))
      echo "$FILESREM files remaining - $PERCENTAGE% complete" '|' 'Runtime:' $(( SECONDS / 60 ))'m '$(( SECONDS % 60 ))'s' '-' $(( $TIMEREM / 60 ))'m '$(( $TIMEREM % 60 ))'s' 'remaining.'
      Convert "$MUSIC" "$OUTPUT/"
      ((INDICATOR++))
    done
    
    echo $(basename "$DIRECTORY") 'is done.'
    echo ''
  done
  unset IFS
  # Reset (unset) IFS
  
  echo 'Batch conversion is finished.'
  echo ''
  exit 0
}

Convert() {
  # Get relative path and filename without extension and problem characters
  local FILENAME=$(echo $(dirname "$1")'/'$(basename "$1" | sed -e 's/\.[^./]*$//' | tr -d "<>*|\\:/\"?" | iconv -f utf8 -t ascii//TRANSLIT))
  local CONVERT="${2}$FILENAME"
  local METADATA=$(ffmpeg -loglevel 'quiet' -i "$1" -metadata 'LYRICS=' -f ffmetadata - | awk -F'=' 'BEGIN {OFS="="} NR > 1 { $1=tolower($1); print $0 }')
  local TAGS=$(BuildTags "$METADATA")
  
  echo 'Converting:' $(basename "$1")
  ffmpeg -loglevel 'error' -stats -y -i "$1" -c:a libfdk_aac -afterburner 1 -cutoff 20000 -ar 44100 -vbr 5 -c:v png -vf scale=600:600:force_original_aspect_ratio=decrease:force_divisible_by=2 "$CONVERT.m4a"
  
  eval AtomicParsley "\"$CONVERT.m4a\"" --overWrite "$TAGS" >/dev/null
  echo 'Done.'
  echo ''
}

ResolveCommands "$@"

