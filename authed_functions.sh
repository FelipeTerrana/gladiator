#!/bin/bash

source params.sh



eatFish()
{
    if [ $SOUPS_TO_BUY -gt 0 ]
    then
        curl --data casa[1]="$SOUPS_TO_BUY" --data Submit752=Levar "$MARKET_ROUTE" > /dev/null
        curl --data quantidade[1]="$SOUPS_TO_BUY" --data usar[1]=Usar "$HOUSE_ROUTE" > /dev/null

        SOUPS_TO_BUY=0
    fi

    if [ $BLUE_FISHES_TO_BUY -gt 0 ]
    then
        curl --data casa[3]="$BLUE_FISHES_TO_BUY" --data Submit772=Levar "$MARKET_ROUTE" > /dev/null
        curl --data quantidade[3]="$BLUE_FISHES_TO_BUY" --data usar[3]=Usar "$HOUSE_ROUTE" > /dev/null

        BLUE_FISHES_TO_BUY=0
    fi
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
