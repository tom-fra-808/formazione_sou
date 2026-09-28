#!/usr/bin/env bash

CONTAINER="echo-server"
IMAGE="ealen/echo-server"

start_container(){
    host="$1"
    vagrant ssh "$host" -c "sudo docker rm -f $CONTAINER >/dev/null 2>&1; sudo docker run -d --name $CONTAINER -p 8080:80 $IMAGE"
}

stop_container(){
        host="$1"

    vagrant shh "$host" -c "sudo docker rm -f $CONTAINER >/dev/null "
}

stop_container pp1
stop_container pp2


echo "Quanto tempo vuoi che aspettino i container? "
read -r time
while true; do
    start_container pp1
    sleep "$time"
    stop_container pp1
    start_container pp2
    sleep "$time"
    stop_container pp2

done
