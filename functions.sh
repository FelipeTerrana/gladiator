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



eatFish()
{
    if [ $SOUPS_TO_BUY -gt 0 ]
    then
        curl --data casa[1]="$SOUPS_TO_BUY" --data Submit752=Levar "$MARKET_ROUTE" > /dev/stdout
        curl --data quantidade[1]="$SOUPS_TO_BUY" --data usar[1]=Usar "$HOUSE_ROUTE" > /dev/stdout

        SOUPS_TO_BUY=0
    fi

    if [ $BLUE_FISHES_TO_BUY -gt 0 ]
    then
        curl --data casa[3]="$BLUE_FISHES_TO_BUY" --data Submit772=Levar "$MARKET_ROUTE" > /dev/stdout
        curl --data quantidade[3]="$BLUE_FISHES_TO_BUY" --data usar[3]=Usar "$HOUSE_ROUTE" > /dev/stdout

        BLUE_FISHES_TO_BUY=0
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



enterArena()
{
    ARENA_RESPONSE=$(curl --data inscrever=Inscrever-se "$ARENA_ROUTE")
    ARENA_SUCCESS=$(echo $ARENA_RESPONSE | grep -o "Inscrição realizada com sucesso!")

    if [ -z "$ARENA_SUCCESS" ]
    then
        log "Erro na inscrição"
        echo "$ARENA_RESPONSE" > "$ARENA_ERROR_FILE"
        closeAndExit 2
    fi

    log "$ARENA_SUCCESS"
}
