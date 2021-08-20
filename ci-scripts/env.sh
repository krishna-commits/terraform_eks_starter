#! /bin/sh

source_vars() {
  VARS=$(aws secretsmanager get-secret-value --secret-id $1 | jq '.SecretString | fromjson' | jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]')
  for keyval in $VARS; do
    export $keyval
  done
}

source_vars $1
