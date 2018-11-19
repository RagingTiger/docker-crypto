#!/bin/bash

# functions
get_passwd(){
  # gen local var to hold password
  local password_input

  # get passphrase
  echo -n "Passphrase: "
  read password_input

  # return passphrase
  echo "$password_input"
}

get_outfile(){
  # gen local var to hold outfile name
  local outname_input

  # get output file name
  echo -n "$1 decrypted output file name: "
  read outname_input
  echo "Decrypting $1 as $outname_input"

  # return
  echo "$outname_input"
}

crypt(){
  # setup initial stuff
  local mode="$(echo $1)"
  local outname="${3:-$3}"
  local passwd="${2:-$2}"
  
  # begin encrypt/decrypt
  for file in "${@:2}"; do
    # get output name
    if [[ "$mode" == "d" ]]; then
      # announce decryption
      if [ -z "$outname" ]; then
        outname=$(get_outfile $file)
      fi

    else
      # get hash
      echo "Current file being encrypted: $file"
      if [ -z "$outname" ]; then
        echo "Defaulting to md5sum of file as name"
        outname=$(md5sum "${file}" | awk '{print $1}')
      fi

      # announce encryption
      echo "Encrypting $file as $outname"
    fi

    # get passphrase
    if [ -z "$passwd" ]; then
      passwd=$(get_passwd)
    fi

    # encrypt/decrypt
    pv "${file}" | openssl enc -aes-256-cbc -$mode -k "$passwd" >> "${outname}"
  done
}

# main
[[ "$(basename $0)" == "encrypt" ]] && crypt "e" "$@"
[[ "$(basename $0)" == "decrypt" ]] && crypt "d" "$@"
