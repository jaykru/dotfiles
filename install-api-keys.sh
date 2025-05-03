#!/bin/sh

for file in `ls .*.gpg`; do
  basename=`echo "$file" | sed 's/\.gpg$//'`
  echo "decrypting $file -> ~/$basename"
  gpg --decrypt $file > $HOME/$basename
done
