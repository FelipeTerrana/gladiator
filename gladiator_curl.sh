#!/bin/bash

source params.sh
source aux_functions.sh



if [ $# -gt 0 ]
then
    ARENA_ROUTE="$TEAM_ARENA_ROUTE"
fi



emulateHumanSlowness

source authenticate.sh
source authed_functions.sh

checkStamina
enterArena
eatFish

closeAndExit
