#!/bin/sh

flags() {
  while test $# -gt 0; do
    case "$1" in
    -p | --port)
      shift
      [ $# = 0 ] && error "No port specified"
      export PORT="$1"
      shift
      ;;
    -h | --host)
      shift
      [ $# = 0 ] && error "No host specified"
      export HOST="$1"
      shift
      ;;
    -k | --key)
      shift
      [ $# = 0 ] && error "No key specified"
      export KEY="$1"
      shift
      ;;
    *)
      export HOST="$1"
      shift
      ;;
    esac
  done
}

flags "$@"

echo "Retrieving $KEY from $HOST:$PORT..."

output=$(ssh -p "$PORT" "$HOST" -oStrictHostKeyChecking=accept-new  "bash -c 'env | grep $KEY'")

echo $output
