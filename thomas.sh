#!/bin/bash

source params.sh
source aux_functions.sh



if [ $# -eq 0 ]
then
    emulateHumanSlowness
fi



source authenticate.sh

while :
do
    FIRST_RESPONSE=$(curl "$TRAIN_ROUTE")

    TRAINS_LEFT=$(getTrainsLeft "$FIRST_RESPONSE")

    if [ $TRAINS_LEFT -eq 0 ]
    then
        log "Treinos esgotados, saindo"
        break
    fi

    CURRENT_STAMINA=$(getStamina "$FIRST_RESPONSE")

    if [ $CURRENT_STAMINA -lt $TRAIN_COST ]
    then
        log "Estamina baixa, comendo semente..."

        curl --data casa[4]=1 --data Submit782=Levar "$MARKET_ROUTE" > /dev/null
        curl --data quantidade[4]=1 --data usar[4]=Usar "$HOUSE_ROUTE" > /dev/null
    fi

    STRENGTH=$(getStrength "$FIRST_RESPONSE")
    OPPONENT=$(getOpponent "$STRENGTH")

    if [ -z $OPPONENT ]
    then
        log "Erro na seleção automática do adversário"
        OPPONENT=$DEFAULT_OPPONENT
    fi

    START_TRAIN_RESPONSE=$(curl "$START_TRAIN_ROUTE""$OPPONENT")
    START_TRAIN_SUCCESS=$(echo "$START_TRAIN_RESPONSE" | grep -o "Treino iniciado com sucesso\|Area de Treino")

    if [ -z "$START_TRAIN_SUCCESS" ]
    then
        log "Erro no início de treino"
        echo "$START_TRAIN_RESPONSE" > trainError.html
        break
    fi

    TRAIN_RESPONSE=$(curl "$TRAIN_ROUTE")
    CAPTCHA_URL=$(getCaptchaUrl "$TRAIN_RESPONSE")

    if [ -z "$CAPTCHA_URL" ]
    then
        curl --data tecnica=24 --data Submit8=Atacar "$TRAIN_ROUTE" > /dev/null
    else
        log "$TRAINS_LEFT treinos sobrando, captcha necessário"
        while :
        do
            curl "$CAPTCHA_URL" --output captcha.png
            CAPTCHA_TEXT=$(/usr/local/bin/python uncaptcha.py captcha.png)

            if [ -n "$CAPTCHA_TEXT" ]
            then
                ATTACK_RESPONSE=$(curl --data confirmacao="$CAPTCHA_TEXT" --data tecnica=24 --data Submit8=Atacar "$TRAIN_ROUTE")
                MISSED_CAPTCHA=$(echo "$ATTACK_RESPONSE" | grep -o "OPS... Você digitou o código errado!")

                if [ -z "$MISSED_CAPTCHA" ]
                then
                    log "Captcha passou!"
                    rm captcha.png
                    break
                else
                    log "Captcha errado, tentando de novo"
                fi
            else
                log "Captcha irregular, tentando de novo"
            fi
        done
    fi
done

closeAndExit
