#!/bin/bash

shopt -s expand_aliases

source params.sh



alias closeAndExit='echo " ---------------------------------------------------------------------- " >> "$LOG_FILE" && exit'



log()
{
    echo "[$(date)] $1" >> "$LOG_FILE"
}



getStamina()
{
    STAMINA_PATTERN='(?<=<div class="status-stamina"> <p>)[0-9]*(?= / [0-9]*</p>)'
    STAMINA=$(echo $1 | grep -oP "$STAMINA_PATTERN")

    echo "$STAMINA"
}



checkStamina()
{
    STAMINA=$(getStamina "$(curl "$ARENA_ROUTE")")

    if [ $STAMINA -lt $ARENA_ENTER_COST ]
    then
        log "Estamina baixa ($STAMINA), comprando e comendo peixes..."
        eatFish
    fi
}



checkForError()
{
    if [ -f "$LOGIN_ERROR_FILE" ] || [ -f "$ARENA_ERROR_FILE" ]
    then
        exit
    fi
}



emulateHumanSlowness()
{
    LOWER_SLEEP_BOUND=$(( 3 * 60 ))
    UPPER_SLEEP_BOUND=$(( 18 * 60 ))
    SLEEP_TIME=$(shuf -i $LOWER_SLEEP_BOUND-$UPPER_SLEEP_BOUND -n 1)

    log "Dormindo por $SLEEP_TIME segundos"
    sleep $SLEEP_TIME
}
