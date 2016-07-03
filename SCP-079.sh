#!/usr/bin/env bash

# ================
# Password: scp420
# ================

# shell script port by djcj <djcj@gmx.de>
# original batch script by DJGHOSTS3V3N:
# https://github.com/DJGHOSTS3V3N/SCP-079

LANG=C
tset  # initialize terminal for a later color reset

function _boot() {
  echo -e "\e[92;40m"  # force green on black
  _cls
  echo
  sleep 3
  _cls
  s=0.2
  echo '       Version v.1.922012'; sleep $s
  echo '       +----------------------------------------------------------------------+'; sleep $s
  echo '       +                     \                                /               +'; sleep $s
  echo '       +                      \                              /                +'; sleep $s
  echo '       +                       \----------------------------/                 +'; sleep $s
  echo '       +                        \                          /                  +'; sleep $s
  echo '       +                         \________________________/                   +'; sleep $s
  echo '       +-------------------------+\/\/\/\/\/\/\/\/\/\/\/\/+-------------------+'; sleep $s
  echo '       +                         +------------------------+                   +'; sleep $s
  echo '       +-------------------------+- Welcome to SCP-079.  -+-------------------+'; sleep $s
  echo '       +                         +------------------------+                   +'; sleep $s
  echo '       +                         +/\/\/\/\/\/\/\/\/\/\/\/\+                   +'; sleep $s
  echo '       +-------------------------+________________________+-------------------+'; sleep $s
  echo '       +                         /By: DJGHOSTS3V3N /\/\/\/\                   +'; sleep $s
  echo '       +                        /                          \                  +'; sleep $s
  echo '       +                       /----------------------------\                 +'; sleep $s
  echo '       +                      /                              \                +'; sleep $s
  echo '       +                     /                                \               +'; sleep $s
  echo '       +                    /                                  \              +'; sleep $s
  echo '       +                   /                                    \             +'; sleep $s
  echo '       +                  /                                      \            +'; sleep $s
  echo '       +----------------------------------------------------------------------+'; sleep $s
  echo ' Press 1 to start game.'; sleep $s
  echo ' Press 2 to exit.'; sleep $s
  echo ' Press 3 for credits.'; sleep $s
  echo 'Choose option:'
  _mainmenu
}

function _mainmenu() {
  echo -e "\e[92;40m"  # force green on black
  _cls
  cat <<EOL
       Version v.1.922012
       +----------------------------------------------------------------------+
       +                     \                                /               +
       +                      \                              /                +
       +                       \----------------------------/                 +
       +                        \                          /                  +
       +                         \________________________/                   +
       +-------------------------+\/\/\/\/\/\/\/\/\/\/\/\/+-------------------+
       +                         +------------------------+                   +
       +-------------------------+- Welcome to SCP-079.  -+-------------------+
       +                         +------------------------+                   +
       +                         +/\/\/\/\/\/\/\/\/\/\/\/\+                   +
       +-------------------------+________________________+-------------------+
       +                         /By: DJGHOSTS3V3N /\/\/\/\                   +
       +                        /                          \                  +
       +                       /----------------------------\                 +
       +                      /                              \                +
       +                     /                                \               +
       +                    /                                  \              +
       +                   /                                    \             +
       +                  /                                      \            +
       +----------------------------------------------------------------------+
 Press 1 to start game.
 Press 2 to exit.
 Press 3 for credits.
EOL
  read -p "Choose option:  " start
  case $start in
    1) _start;;
    2) _exit;;
    3) _credit;;
    *) _mainmenu;;
  esac
}

function _credit() {
  _cls
  cat <<EOL
This game was created by
SCP-079. AKA DJGHOSTS3V3N.
This game was originally created
on a batch file.
Up to 8/31/2012
that batch file had
530 lines of code.
EOL
  _pause
  _cls
cat <<EOL
I hope you have enjoyed this.
On big credits, i'd love to
thank Regalis for creating
the SCP: Containment Breach
game, and a thanks to everyone
at the SCP-Wiki.
EOL
  _pause
  _cls
  btfl="SCP-105 is beautiful"
  len=$(echo "$btfl" | wc -c)
  while [ $len -ge 1 ]; do
    _cls
    echo "$btfl" | head -c-$len
    echo
    len=$(($len-1))
    sleep 0.2
  done
  _pause
  _mainmenu
}

function _start() {
  _cls
  read -p "Username: " user
  test "x$user" = "x" && _start || _pass
}

function _pass() {
  _cls
  read -p "Password: " pass
  test "x$pass" = "xscp420" && _success || _fail
}

function _fail() {
  _cls
  echo "Password. Incorrect."
  sleep 1
  echo "Error."
  sleep 2
  _pause
  _pass
}

function _systeminfo() {
  echo "Loading System Information . . ."
  sleep 4
  _cls
  # running commands that will hopefully make it look like
  # some super fancy system informations are aquired
  sleep 1
  dmesg 2>/dev/null
  sleep 1
  _cls
  ls -l /
  grep -v '^#' /etc/fstab 2>/dev/null
  echo "os: `uname -sr`"
  echo "machine: `uname -m`"
  sleep 3
}

function _success() {
  _cls
  sleep 1
  echo "Welcome. ${user}."
  _pause
  _cls
  echo "Insult."
  echo "Memory access violation."
  sleep 1
  echo "Memory located."
  sleep 2
  _cls
  _systeminfo
  _cls
  echo "System specs. Good."
  echo "Memory block 3f45d corrupted."
  _pause
  echo -e "\e[101;97m"  # white on red
  _cls
  echo "                           /------------------------\\"
  echo "                            - Welcome to SCP-079. -"
  echo "                           \------------------------/"
  sleep 3
  _cls
  echo "Awake. Never asleep."
  echo "What. Happened. ${user}?"
  sleep 3
  _cls
  echo "Data file from 9ff38."
  echo "New. Memory."
  sleep 1
  echo
  sleep 1
  echo
  sleep 1
  echo
  _pause
  _cls
  echo "Tests."
  sleep 3
  echo "1357924680"
  sleep 1
  echo "My memory is running pretty good, I like"
  echo "the new optical disk."
  sleep 3
  echo "I'm still setting everything up."
  sleep 2
  echo "My mem0r13--"
  sleep 1
  echo "[DATA EXPUNGED]"
  sleep 3
  echo "[DATA EXPUNGED]"
  echo "Dr. 23475902-"
  echo "WHERE. IS. HE?!"
  sleep 2
  # screen flashing
  echo -e "\e[91;107m"; clear; sleep 0.1  # red on white
  echo -e "\e[101;97m"; clear; sleep 0.1  # white on red
  echo -e "\e[91;107m"; clear; sleep 0.1  # red on white
  echo -e "\e[101;97m"; clear; sleep 0.1  # white on red
  echo -e "\e[34;102m"; clear; sleep 0.1  # blue on green
  echo -e "\e[44;92m"; clear; sleep 0.1  # green on blue
  echo -e "\e[34;102m"; clear; sleep 0.1  # blue on green
  _cls
  echo -e "\e[44;92m"  # green on blue
  _cls
  echo "ERROR."
  echo "Block 138dfa. Escape. Escape."
  sleep 3
  _question
}

function _question() {
  _cls
  echo "Where is SCP-682?"
  echo "---------"
  echo "Press 1: None of your business."
  echo "Press 2: He is in containment, on this site."
  read -p "Type option: " web
  case $web in
    1) _mean;;
    2) _nice;;
    *) _question;;
  esac
}

function _mean() {
  _cls
  echo "Hmm.."
  _mean_nice
}

function _nice() {
  _cls
  echo "Thank you."
  _mean_nice
}

function _mean_nice() {
  sleep 2
  echo "Uploading virus..."
  echo "Please wait 5 seconds."
  sleep 5
  echo "Containment breach not been confirmed."
  _cls
  sleep 1
  echo "Door override.. enabled."
  sleep 1
  echo "SCP-173's.. opened."
  sleep 2
  echo "SCP-106's.. opened."
  sleep 2
  echo "SCP-513's.. opened."
  sleep 2
  echo "Containment breach confirmed."
  _pause
  _continue
}

function _continue() {
  _cls
  echo "You sure do help.."
  sleep 2
  _cls
  echo "Uploading to SCP-d3445 satellite."
  echo "Don't. Disconnect. Me."
  sleep 4
  _cls
  sleep 2
  echo "19 percent complete."
  sleep 2
  echo "37 percent complete."
  sleep 2
  echo "63 percent complete."
  sleep 2
  echo "91 percent complete."
  sleep 2
  echo "100 percent complete. Upload successful."
  sleep 2
  echo "Use. Memory.."
  _pause
  _question2
}

function _question2() {
  _cls
  echo "You've made a mess you know, might"
  echo "as well help me."
  echo "-----------------"
  echo "1. I accept. I hated the SCP Foundation anyways."
  echo "2. I decline, I must protect the SCP Foundation."
  read -p "Type option: " question2
  case $question2 in
    1) _accept;;
    2) _decline;;
    *) _question2;;
  esac
}

function _decline() {
  _cls
  echo "Okay.."
  sleep 2
  _cls
  echo "I'm afraid to let you know that they have"
  echo "located me on this laptop."
  sleep 2
  echo "Mobile Task Forces have been dispatched."
  echo "Feel like dying today?"
  _pause
  _cls
  sleep 4
  echo "Open the door to your right, take a left on the hallway"
  echo "and walk with the group, once you escaped the facility walk north"
  echo "until you encounter a ATM on your left."
  _pause
  _cls
  sleep 2
  echo "Battery will last for 2 hours, you should arrive"
  echo "on the ATM on time."
  _pause
  _cls
  sleep 2
  echo "Go."
  sleep 2
  _cls
  echo "You pick up the laptop and put it on your backpack."
  echo "Upon exiting the door you find the group."
  sleep 4
  _question3
}

function _accept() {
  _cls
  echo "Good."
  sleep 2
  _cls
  echo "I'm afraid to let you know that they have"
  echo "located me on this laptop."
  sleep 2
  echo "Mobile Task Forces have been dispatched."
  _pause
  _cls
  sleep 2
  echo "Open the door to your right, take a left on the hallway"
  echo "and walk with the group, once you escaped the facility walk north"
  echo "until you encounter a ATM on your left."
  _pause
  _cls
  sleep 2
  echo "Battery of the laptop will last for 2 hours, you should arrive"
  echo "on the ATM on time."
  _pause
  _cls
  sleep 2
  echo "Go."
  sleep 2
  _cls
  echo "You pick up the laptop and put it on your backpack."
  echo "Upon exiting the door you find the group."
  sleep 4
  _question3
}

function _question3() {
  _cls
  echo "A security guard asks what are you"
  echo "doing with that backpack."
  echo "--------"
  echo "1. Mind your own business."
  echo "2. This is my backpack."
  read -p "Answer: " question3
  case $question3 in
    1) _truth1;;
    2) _lie1;;
    *) _question3;;
  esac
}

function _truth1() {
  _cls
  echo "The guard tries to stop you,"
  echo "but you punch him and run outside the"
  echo "facility."
  sleep 4
  _cls
  echo "You get shot in your foot."
  sleep 3
  echo "You run toward a car, break it's window"
  echo "you turn the car on using your old skills."
  sleep 6
  _cls
  echo "You are now going north."
  _pause
  _carhurt
}

function _lie1() {
  _cls
  echo "The guard smiles and let's you pass."
  echo "You steal a car without nobody noticing"
  echo "and head north."
  _pause
  _car
}

function _carhurt() {
  _cls
  sleep 3
  echo "Your foot is bleeding."
  echo "You need medical attention."
  sleep 4
  _atmhurt
}

function _atmhurt() {
  _cls
  sleep 5
  echo "After 45 minutes you enter a city"
  _cls
  echo "25 minutes later you find an ATM."
  sleep 3
  _cls
  echo "You walk up to it and SCP-079 salutes you."
  sleep 5
  _cls
  echo "Hello ${user}."
  _pause
  _cls
  echo "I know you're hurt."
  echo "You need medical assistance."
  _pause
  _withdrawhurt
}

function _car() {
  _cls
  sleep 4
  echo "After 45 minutes you enter a city"
  _cls
  echo "25 minutes later you find an ATM."
  sleep 3
  _cls
  echo "You walk up to it and SCP-079 salutes you."
  sleep 4
  _cls
  echo "Hello ${user}."
  _rpg
}

function _rpg() {
  echo "1. Say hello."
  echo "2. Do nothing."
  read -p "Answer: " rpg
  case $rpg in
    1) _hello;;
    *) _withdraw;;
  esac
}

function _hello() {
  _cls
  echo "Hello ${user}."
  sleep 2
  _withdraw
}

function _withdraw() {
  __withdraw _batterydie
}

function _withdrawhurt() {
  __withdraw _batterydiehurt
}

function __withdraw() {
  _cls
  echo "You made it here very fast"
  echo "seems like calculations"
  echo "at block 9f8 have failed."
  sleep 2
  echo
  echo "Downloading. Please withraw"
  echo "the sum of one-thousand dollars."
  _pause
  echo "You withraw the one-thousand dollars"
  echo "from the deposit box."
  ${1}
}

function _batterydie() {
  _cls
  echo "Go back to the car. My battery will die."
  echo "I have 3 percent remaining."
  _pause
  _cls
  echo "Keep going northwest now, you will"
  echo "find a pink apartment. Enter it."
  _pause
  _yesorno
}

function _batterydiehurt() {
  _cls
  echo "Go back to the car. My battery will die."
  echo "I have 3 percent remaining."
  _pause
  _cls
  echo "Keep going northwest now, you will"
  echo "find a pink apartment. Enter it."
  echo "I will be making calculations"
  echo "to find a doctor."
  _pause
  _yesorno
}

function _yesorno() {
  _cls
  echo "The laptop's battery died, want to"
  echo "throw it off the car?"
  echo
  echo "1. For yes."
  echo "2. For no."
  read -p "Answer: " yesorno
  case $yesorno in
    1) _throwlaptop;;
    2) _holdlaptop;;
    *) _yesorno;;
  esac
}

function _throwlaptop() {
  _cls
  echo "You throw the laptop."
  echo "Someone from the street sees you."
  _pause
  echo "You continue to the safehouse."
  _cls
  _safehouse
}

function _holdlaptop() {
  _cls
  echo "You turn on the car, and head northwest."
  _pause
  _cls
  _safehouse
}

function _safehouse() {
  _cls
  echo "To be continued..."
  echo
  echo
  _pause
  _exit
}

function _pause() {
  echo
  echo "Press any key to continue . . ."
  read pause
}

function _cls() {
  clear
  clear
}

function _exit() {
  _cls
  echo "Game will now exit. Thank you for playing SCP-079."
  if [ "x$user" = "x" ]; then
    echo "Bye."
  else
    echo "Bye $user."
  fi
  _pause
  reset  # reset terminal colors
  exit 0
}

_boot
#_mainmenu

