#!/bin/sh

user=""
password=""
database=""
pathName="server1"
while [ $# -gt 0 ]
do
    case "$1" in
      -u)  user="$2"; shift;;
      -p)  password="$2"; shift;;
      -d)  database="$2"; shift;;
      -n)  pathName="$2"; shift;;
      --) shift; break;;
      -h)
          echo >&2 \
          "usage: $0 -u username -p password -d database -n shortPathName"
          exit 1;;
      *)  break;; # terminate while loop
    esac
    shift
done

if test -z $user || test -z $password || test -z $database; then
  echo "not all args defined"
  exit 1
fi

hostPath="/home/allecs/Workspace/MongoDB/$pathName"
imageName="node3030/mongo-auth"

docker run -d -e MONGO_PASSWD=$password --name mongod -d -v $hostPath:/data/db $imageName --storageEngine wiredTiger --auth
sleep 3s
docker exec -it mongod mongo $database --eval \
  "if (!(db.system.users.find({user:'$user'}))) db.createUser( { user:'$user' , pwd:'$password', roles: [ { role: 'userAdminAnyDatabase', db: '$database' } ] })"
