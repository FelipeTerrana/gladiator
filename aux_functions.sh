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



getTrainsLeft()
{
    TRAINS_PATTERN='(?<=VOC&Ecirc; AINDA PODE REALIZAR <strong><font color="#00BFFF">)[0-9]*(?=</font></strong> TREINOS)'
    TRAINS=$(echo $1 | grep -oP "$TRAINS_PATTERN")

    if [ -z "$TRAINS" ]
    then
        echo "0"
    else
        echo "$TRAINS"
    fi
}



getCaptchaUrl()
{
    CAPTCHA_PATTERN='(?<=<img src=")securimage.php\?rand=[0-9]*(?=" alt="" align="absmiddle">)'
    CAPTCHA_URL=$(echo "$1" | grep -oP "$CAPTCHA_PATTERN")

    if [ -n "$CAPTCHA_URL" ]
    then
        echo "$BASE_ROUTE""$CAPTCHA_URL"
    fi
}



getStrength()
{
    STRENGTH_PATTERN='(?<=<strong>For&ccedil;a</strong> </td> <td width="10" height="15">&nbsp;</td> </tr> <tr> <td height="15">&nbsp;</td> <td width="20" height="15">&nbsp;</td> <td width="110" height="15">)[0-9]*(?=</td>)'
    STRENGTH=$(echo $1 | grep -oP "$STRENGTH_PATTERN")

    echo "$STRENGTH"
}



getOpponent()
{
    /usr/local/bin/python -c "print(int((32 / 19000) * $1))"
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
