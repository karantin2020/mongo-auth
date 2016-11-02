#!/bin/sh

while [ $# -gt 0 ]
do
    case "$1" in
      -u)  user="$2"; shift;;
      -p)  password="$2"; shift;;
      -d)  database="$2"; shift;;
      --) shift; break;;
      -h)
          echo >&2 \
          "usage: $0 -u username -p password -d database"
          exit 1;;
      *)  break;; # terminate while loop
    esac
    shift
done

if test -z $user || test -z $password || test -z $database; then
  echo "not all args defined"
  exit 1
fi

imageName="node3030/mongo-auth"
containerName="mongod"

docker run -it --rm --link $containerName:mongo $imageName mongo -u $user -p $password --authenticationDatabase $database $containerName/$database