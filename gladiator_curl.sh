#!/bin/bash

source params.sh
source aux_functions.sh



checkForError
emulateHumanSlowness

source authenticate.sh
source authed_functions.sh

checkStamina
enterArena
eatFish

closeAndExit
