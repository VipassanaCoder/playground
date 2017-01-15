#!/bin/bash

source $(dirname $0)/paths.sh

trap "echo Exiting...; exit;" SIGINT SIGTERM

playground=$1
shift

cmd="$SCRIPTSDIR/play.sh -p $playground -WR"

while : ; do
  echo "$1" | entr sh -c "$cmd; sleep 1"  #entr $(build-playground && run-playground)
done
