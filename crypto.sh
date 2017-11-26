#!/bin/bash

# functions
crypt(){
  # setup initial stuff
  local mode="$(echo $1)"
  local outname=""
  local passwd=""

  # begin encrypt/decrypt
  for file in "${@:2}"; do
    # get output name
    if [[ "$mode" == "d" ]]; then
      # announce decryption
      echo -n "${file} decrypted output file name: "
      read outname
      echo "Decrypting $file as $outname"
    else
      # get hash
      echo "$file"
      outname=$(md5sum "${file}" | awk '{print $1}')

      # announce encryption
      echo "Encrypting $file as $outname"
    fi

    # get passphrase
    echo -n "Passphrase: "
    read passwd

    # encrypt/decrypt
    pv "${file}" | openssl enc -aes-256-cbc -$mode -k "$passwd" >> "${outname}"
  done
}

# main
[[ "$(basename $0)" == "encrypt" ]] && crypt "e" "$@"
[[ "$(basename $0)" == "decrypt" ]] && crypt "d" "$@"

