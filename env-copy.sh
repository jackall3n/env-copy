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
      echo "env-copy -p <port> [host] -k <KEY_NAME> --decode"
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

echo "Connecting..."
echo $(run "echo Connected")

echo "Searching variables for '$KEY' from $HOST:$PORT..."

keys=$(run "env | grep $KEY | cut -d '=' -f1")
keys=($keys)

if [ ${#keys[@]} -eq 0 ]; then
    echo "There are no keys matching '$KEY'"
    exit 0
fi

i=-1
for key in "${keys[@]}"; do
  i=$((i + 1))
  echo "$i: $key"
done

read -p "Which key would you like? [0-9]: " -r key_index

if [ "$key_index" -gt $i ]; then
    echo "Invalid selection"
    exit 1
fi

key=${keys[$key_index]}

echo "Printing... $key"

value=$(run "echo \$$key")

export TEST=$value

value=$(echo "$value" | tr '\n' ' ')

echo "Raw:"
echo "$value"

# Print
if [[ $DECODE == 1 ]]; then
  value=$("$value" | base64 -d)
  echo "Decoded:"
  echo "$value"
fi

# Copy if possible
echo "$value" | pbcopy

project_id=$(jq '.project_id' <<< "$value")
private_key_id=$(jq '.private_key_id' <<< "$value")
client_email=$(jq '.client_email' <<< "$value")

echo "key: $key"
echo "client_email: $client_email"
echo "project_id: $project_id"
echo "private_key_id: $private_key_id"

# Copy if possible
echo "$key\t$client_email\t$project_id\t$private_key_id" | pbcopy
