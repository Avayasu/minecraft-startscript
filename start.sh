#!/bin/bash

#COLORS

GR="\033[0;32m"
NC="\033[0m"
RED="\033[0;31m"

#---CONFIG----

rootdir="home/craft" 
Xmx="1024" 
jarfile="server.jar" 

#-------------

serverz=( $(find . -maxdepth 1 !  -path . -type d  -exec basename {} \; |  xargs -0) )

if [ "$(id -u)" != "0" ]; then
   echo "Musis byt root aby ti ten script fungoval" 1>&2
   exit 1
fi

function start {
    optz=("Zapnout vsechny server" "Zapnout jeden server")
        printf "${RED}Vyber si:${NC}\n"
            select optz in "${optz[@]}"; do
                case $REPLY in
                        1) allstart; break ;;
                        2) onestart; break ;;
                        *) echo "Coze?" ;;
                esac
            done
}

function stop {
    opts=("Vypnout vsechny servery" "Vypnout jeden server")
        printf "${RED}Vyber si:${NC}\n"
            select opts in "${opts[@]}"; do
                case $REPLY in
                    1) shutall; break ;;
                    2) shutone; break ;;
                    *) echo "Coze?" ;;
                esac
            done
}

function allstart {
        printf "        \n"
        printf "${GR}Startuji server...${NC}\n"
        for d in ./*/ ; do (cd "$d" && n=${PWD##*/}; screen -AmdS $n java -Xms128M -Xmx"$Xmx"M -jar $jarfile); done
        printf "${GR}Hotovo${NC}\n"
        printf "        \n"
}

function onestart {
        printf "${RED}Vyber server:${NC}\n"
        select server in "${serverz[@]}" "Ukoncit" ; do
            if (( REPLY == 1 + ${#serverz[@]} )) ; then
                exit
            elif (( REPLY > 0 && REPLY <= ${#serverz[@]} )) ; then
                printf "${GR}Vybral jsi $server pod cislem $REPLY${NC}\n"
                break

            else
                echo "${RED}Nespravna volba, zkus to znovu${NC}\n"
            fi
        done
    printf "    \n"
    printf "${GR}Startuji server...${NC}\n"
    cd "/$rootdir/$server" && n=${PWD##*/}; screen -AmdS $n java -Xms128M -Xmx"$Xmx"M -jar $jarfile
      if ! screen -list | grep -q "$n"; then
        printf "${RED}Server se nepodarilo nastartovat${NC}\n"
        printf "    \n"
        break

    else
        printf "${GR}Hotovo${NC}\n"
        printf "    \n"
    fi
}

function shutall {
    printf "    \n"
    printf "${GR}Vypinam servery...${NC}\n"
    for d in ./*/ ; do (cd "$d" && n=${PWD##*/}; screen -X -S $n quit); done
    printf "${GR}Hotovo${NC}\n"
    printf "    \n"
}

function shutone {
        printf "${RED}Vyber server:${NC}\n"
        select server in "${serverz[@]}" "Ukoncit" ; do
            if (( REPLY == 1 + ${#serverz[@]} )) ; then
                exit
            elif (( REPLY > 0 && REPLY <= ${#serverz[@]} )) ; then
                printf "${GR}Vybral jsi $server pod cislem $REPLY${NC}\n"
                break

            else
                echo "${RED}Nespravna volba, zkus to znovu${NC}\n"
            fi
        done
    printf "    \n"
    printf "${GR}Vypinam server...${NC}\n"
    cd "/$rootdir/$server" && n=${PWD##*/}; screen -X -S $n quit
        printf "${GR}Hotovo${NC}\n"
        printf "    \n"
}

function delete {
        printf "${RED}Vyber server:${NC}\n"
        select server in "${serverz[@]}" "Ukoncit" ; do
            if (( REPLY == 1 + ${#serverz[@]} )) ; then
                exit
            elif (( REPLY > 0 && REPLY <= ${#serverz[@]} )) ; then
                printf "${GR}Vybral jsi $server pod cislem $REPLY${NC}\n"
                break

            else
                echo "${RED}Nespravna volba, zkus to znovu${NC}\n"
            fi
        done
    printf "    \n"
    printf "${GR}Mazu server...${NC}\n"
    rm -rf $server
    printf "${GR}Hotovo${NC}\n"
    printf "    \n"
}

function console {
        printf "${RED}Vyber server:${NC}\n"
        select server in "${serverz[@]}" "Ukoncit" ; do
            if (( REPLY == 1 + ${#serverz[@]} )) ; then
                exit
            elif (( REPLY > 0 && REPLY <= ${#serverz[@]} )) ; then
                printf "${GR}Vybral jsi $server pod cislem $REPLY${NC}\n"
                break

            else
                echo "${RED}Nespravna volba, zkus to znovu${NC}\n"
            fi
        done
        cd "/$rootdir/$server" && n=${PWD##*/}; screen -r $n
}

all_done=0
while (( !all_done )); do
        options=("Start" "Stop" "Jit do konzole" "Vymazat server")

        printf "${RED}Vyber si:${NC}\n"
        select opt in "${options[@]}"; do
                case $REPLY in
                        1) start; break ;;
                        2) stop; break ;;
                        3) console; break ;;
                        4) delete; break ;;
                        *) echo "Coze?" ;;
                esac
        done

        printf "${RED}Mas vse hotovo?${NC}\n"
        select opt in "Ano" "Ne"; do
                case $REPLY in
                        1) all_done=1; break ;;
                        2) break ;;
                        *) echo "Hele, je to jednoducha otazka..." ;;
                esac
        done
done
