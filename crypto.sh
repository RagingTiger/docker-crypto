#!/bin/bash

# functions
prompt(){
  echo -n "$1"
}

get_input(){
  # gen local var
  local user_input

  # get input
  read user_input

  # return input
  echo "$user_input"
}

crypt(){
  # setup initial stuff
  local mode="$(echo $1)"
  local inputname="${2:-}"
  local passwd="${3:-}"
  local outname="${4:-}"

  ## begin encrypt/decrypt
  # get output name
  if [[ "$mode" == "d" ]]; then
    # announce decryption
    if [ -z "$outname" ]; then
      prompt "$inputname decrypted output file name: "
      outname=$(get_input)
      echo "$inputname decrypted as $outname"
    fi

  else
    # get hash
    echo "Current file being encrypted: $2"
    if [ -z "$outname" ]; then
      echo "Defaulting to md5sum of file as output name"
      outname=$(md5sum "$inputname" | awk '{print $1}')
    fi

    # announce encryption
    echo "Encrypting $2 as $outname"
  fi

  # get passphrase
  if [ -z "$passwd" ]; then
    prompt "Passphrase: "
    passwd=$(get_input)
  fi

  # encrypt/decrypt
  pv "$inputname" | openssl enc -aes-256-cbc -$mode -k "$passwd" >> "${outname}"
}

# globals
password=
outfile=
infile=
fvalflag=

# main
while getopts ":p:o:f:" opt; do
  case $opt in
    p)
      # get password arg
      password="$OPTARG"
      ;;
    o)
      # get outfile arg
      outfile="$OPTARG"
      ;;
    f)
      # set -f flag true
      fvalflag=true

      # get infile arg
      infile="$OPTARG"

      # check encrypt
      if [[ "$(basename $0)" == "encrypt" ]]; then
        if [ -z "$password" ]; then
          echo "Error: -p option must be set before -f option for encryption"
        else
          crypt "e" "$infile" "$password" "$outfile"
        fi
      fi

      # check decrypt
      if [[ "$(basename $0)" == "decrypt" ]]; then
        if [ -z "$password" ] || [ -z "$outfile" ]; then
          echo -n "Error: -o and -p options must be set before -f option "
          echo "for decryption" 1>&2
        else
          crypt "d" "$infile" "$password" "$outfile"
        fi
      fi
      ;;
    :)
      echo "Invalid option: -$OPTARG requires an argument" 1>&2
      exit
      ;;
  esac
done

# execute
shift $((OPTIND-1))
if [ ! "$fvalflag" ] && [ -n "$*" ]; then
  # run encrypt/decrypt
  [[ "$(basename $0)" == "encrypt" ]] && crypt "e" "$1" "$password" "$outfile"
  [[ "$(basename $0)" == "decrypt" ]] && crypt "d" "$1" "$password" "$outfile"

  # if un linked
  if [[ "$(basename $0)" == "crypto.sh" ]]; then
    echo "Expects for command to be named \"encrypt\" or \"decrypt\""
    echo "Please create these by \"linking\" them to the crypto.sh file as such:"
    echo "\$ ln crypto.sh encrypt"
    echo "\$ ln crypto.sh decrypt"
  fi
fi
