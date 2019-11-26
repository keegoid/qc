#!/bin/bash
# --------------------------------------------
# Define constants for background and
# foreground colors
#
# Author : Keegan Mullaney
# Website: keegoid.com
# Email  : keegan@kmauthorized.com
# License: keegoid.mit-license.org
# --------------------------------------------

{ # this ensures the entire script is downloaded #

LKM_DEBUG_COLORS=1

# --------------------------  DECLARE COLOR VARIABLES

declare -r COLOR='\033[0'

declare -r BLACK='0'
declare -r RED='1'
declare -r GREEN='2'
declare -r YELLOW='3'
declare -r BLUE='4'
declare -r PURPLE='5'
declare -r TEAL='6'
declare -r GRAY='7'
declare -r WHITE='9'

declare -r FG='3'
declare -r BG='4'

# --------------------------  BACKGROUND COLORS

declare -r GRAY_BLACK="${COLOR};${BG}${GRAY};${FG}${BLACK}m"
declare -r TEAL_BLACK="${COLOR};${BG}${TEAL};${FG}${BLACK}m"
declare -r PURPLE_BLACK="${COLOR};${BG}${PURPLE};${FG}${BLACK}m"
declare -r BLUE_BLACK="${COLOR};${BG}${BLUE};${FG}${BLACK}m"
declare -r YELLOW_BLACK="${COLOR};${BG}${YELLOW};${FG}${BLACK}m"
declare -r GREEN_BLACK="${COLOR};${BG}${GREEN};${FG}${BLACK}m"
declare -r RED_BLACK="${COLOR};${BG}${RED};${FG}${BLACK}m"
declare -r BLACK_WHITE="${COLOR};${BG}${BLACK};${FG}${WHITE}m"

# --------------------------  FOREGROUND COLORS

declare -r NONE_GRAY="${COLOR};0;${FG}${GRAY}m"
declare -r NONE_TEAL="${COLOR};0;${FG}${TEAL}m"
declare -r NONE_PURPLE="${COLOR};0;${FG}${PURPLE}m"
declare -r NONE_BLUE="${COLOR};0;${FG}${BLUE}m"
declare -r NONE_YELLOW="${COLOR};0;${FG}${YELLOW}m"
declare -r NONE_GREEN="${COLOR};0;${FG}${GREEN}m"
declare -r NONE_RED="${COLOR};0;${FG}${RED}m"
declare -r NONE_BLACK="${COLOR};0;${FG}${BLACK}m"

# --------------------------  DEFAULT

declare -r NONE_WHITE="${COLOR};0;${FG}${WHITE}m"

# --------------------------  COLORED SYMBOLS

declare -r GREEN_CHK="${NONE_GREEN}✔${NONE_WHITE}"
declare -r YELLOW_CHK="${NONE_YELLOW}✔${NONE_WHITE}"
declare -r BLUE_CHK="${NONE_BLUE}✔${NONE_WHITE}"
declare -r BLACK_CHK="${NONE_BLACK}✔${NONE_WHITE}"
declare -r RED_X="${NONE_RED}✘${NONE_WHITE}"

# --------------------------  TESTING

if [ "$LKM_DEBUG_COLORS" -eq 0 ]; then
  echo -e "${GRAY_BLACK} ...some text... ${NONE_WHITE}"
  echo -e "${TEAL_BLACK} ...some text... ${NONE_WHITE}"
  echo -e "${PURPLE_BLACK} ...some text... ${NONE_WHITE}"
  echo -e "${BLUE_BLACK} ...some text... ${NONE_WHITE}"
  echo -e "${YELLOW_BLACK} ...some text... ${NONE_WHITE}"
  echo -e "${GREEN_BLACK} ...some text... ${NONE_WHITE}"
  echo -e "${RED_BLACK} ...some text... ${NONE_WHITE}"
  echo -e "${BLACK_WHITE} ...some text... ${NONE_WHITE}"

  echo -e "${NONE_WHITE} ...some text... ${NONE_WHITE}"
  echo -e "${NONE_GRAY} ...some text... ${NONE_WHITE}"
  echo -e "${NONE_TEAL} ...some text... ${NONE_WHITE}"
  echo -e "${NONE_PURPLE} ...some text... ${NONE_WHITE}"
  echo -e "${NONE_BLUE} ...some text... ${NONE_WHITE}"
  echo -e "${NONE_YELLOW} ...some text... ${NONE_WHITE}"
  echo -e "${NONE_GREEN} ...some text... ${NONE_WHITE}"
  echo -e "${NONE_RED} ...some text... ${NONE_WHITE}"
  echo -e "${NONE_BLACK} ...some text... ${NONE_WHITE}"

  echo -e "${GREEN_CHK} ...some text..."
  echo -e "${YELLOW_CHK} ...some text..."
  echo -e "${BLUE_CHK} ...some text..."
  echo -e "${BLACK_CHK} ...some text..."
  echo -e "${RED_X} ...some text..."
fi

} # this ensures the entire script is downloaded #
