#!/bin/bash

shopt -s expand_aliases

source params.sh
source aux_functions.sh

COOKIE=$(curl --user-agent "$USER_AGENT" -I "$COOKIE_MAKER_ROUTE" | grep -o "PHPSESSID=[0-9|a-z]*")

alias curl='curl --user-agent "$USER_AGENT" --cookie $COOKIE'

LOGIN_RESPONSE=$(curl --data logando=$LOGIN --data senha=$(cd .credentials/ && ./h0jw9i3 && cd ..) --data Submit2=Entrar $LOGIN_POST_ROUTE)
WELCOME=$(echo $LOGIN_RESPONSE | grep -o "\.:: Bem vindo .*! ::\.")

if [ -z "$WELCOME" ]
then
  log "Erro no login"
  echo "$LOGIN_RESPONSE" > "$LOGIN_ERROR_FILE"
  closeAndExit 1
fi

log "$WELCOME"
