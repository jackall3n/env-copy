#!/bin/bash

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
    -d | --decode)
      shift
      export DECODE=1
      shift
      ;;
    --help)
      shift
      echo "env-copy -p <port> [host] -k <KEY_NAME>"
      exit 0
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

if [ -z "$KEY" ]; then
  KEY="SERVICE_KEY"
fi

if [ -z "$PORT" ]; then
  echo "I need a port"
  exit 1
fi

if [ -z "$HOST" ]; then
  echo "I need a host"
  exit 1
fi

run() {
  echo $(ssh -p "$PORT" "$HOST" -oStrictHostKeyChecking=accept-new "bash -c '$1'")
}

echo "Retrieving $KEY from $HOST:$PORT..."

run "echo Connected"

keys=$(run "env | grep $KEY | cut -d '=' -f1")

keys=($keys)

i=0

for key in "${keys[@]}"; do
  echo "$i: $key"
  i=$((i + 1))
done

read -p "Which key would you like? [0-9]: " -r key_index

echo "Printing... ${keys[$key_index]}"

value=$(run "echo \$${keys[$key_index]}")

echo "Raw:"
echo "$value"

if [[ $DECODE == 1 ]]; then
  echo "Decoded:"
  echo "$value" | base64 -d
fi
