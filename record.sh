#!/bin/bash

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
output_folder="./montage"
start_index=0
time_interval=5
delay=0
framerate=30

function stitch_video {
  if ! [ -x "$(command -v ffmpeg)" ]; then
    echo "Error: ffmpeg is not installed." >&2
    echo "Try running \$brew install ffmpeg" >&2
    exit 1
  fi
  ffmpeg -r 30 -start_number $start_index -i $output_folder/%d.png -vcodec libx264 -pix_fmt yuv420p $output_folder/montage.mp4
  exit 0
}

while getopts "o:i:t:yd:hs" opt; do
  case "$opt" in
    o)  output_folder=$OPTARG
      ;;
    i)  start_index=$OPTARG
      ;;
    t)  time_interval=$OPTARG
      ;;
    y)  force_start=1
      ;;
    d)  delay=$OPTARG
      ;;
    h)  print_help
      ;;
    s)  stitch_video
      ;;
    \?) echo "Invalid option: -$OPTARG" >&2
        exit 1
      ;;
  esac
done

function print_help {
  echo "This script records screenshots at regular intervals to a folder"
  echo "Montage recorder configuration:"
  echo " -o Output folder: $output_folder"
  echo " -i Start index:   $start_index"
  echo " -t Time interval: $time_interval"
  echo " -y Force start (non-interactive)"
  echo " -d Delay:         $delay"
}

#shift $((OPTIND-1))

if [ -z ${force_start+x} ]; then
  read -r -p "Ready? [y/N] " response

  if ! [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    exit 1
  fi
fi

function countdown {
  secs=5
  while [ $secs -gt 0 ]; do
    echo -n "$secs... "
    : $((secs--))
    sleep 1
  done
  echo "Starting recording!"
}

countdown

function begin_recording {
  recorded=$start_index

  mkdir -p $output_folder

  while true
  do
    recorded=$(($recorded+1))
    screencapture -x "$output_folder/$recorded.png"
    echo "Recorded screenshot $recorded to $output_folder"
    sleep $time_interval
  done  
}

begin_recording
