#!/usr/bin/env bash

# Colori
    ROSSO="\033[31m"
    VERDE="\033[32m"
    GIALLO="\033[33m"
    BLU="\033[34m"
    MAGENTA="\033[35m"
    GRASSETTO="\033[1m"
    RESET="\033[0m"
#imposto vars
    SPO_SX="sponda_sx"
    SPO_DX="sponda_dx"

    A="sinistra"
    L="sinistra"
    P="sinistra"
    C="sinistra"
#funzioni
    inizializza_container(){
        docker rm -f "$SPO_SX" "$SPO_DX" >/dev/null 2>&1 

        docker run -dit --name "$SPO_SX" ubuntu:22.04 bash >/dev/null
        docker run -dit --name "$SPO_DX" ubuntu:22.04 bash >/dev/null

        for attore in A L P C; do
            start_process "$attore"
        done
    }
    lista_sponda(){
        sponda="$1"
        list=

        for attore in A L P C; do
            if [ "$(verifica_posizione "$attore")" = "$sponda" ]; then
                list="$list $attore"
            fi
        done

        echo "$list"
    }
    verifica_posizione(){
        case "$1" in
            A|a) echo "$A"
            ;;
            L|l) echo "$L"
            ;;
            P|p) echo "$P"
            ;;
            C|c) echo "$C"
            ;;
        esac
    }
    mostra_stato(){
        echo -e "${MAGENTA}||=========================||"
        echo -e "  ${RESET}${GIALLO}Sponda sinistra:${RESET}${VERDE}${GRASSETTO}$(lista_sponda sinistra)${RESET}"
        echo -e "${BLU}  ~~~~~~~~~ FIUME ~~~~~~~~~  ${RESET}"
        echo -e "${MAGENTA}  ${RESET}${GIALLO}Sponda destra:${RESET}${VERDE}${GRASSETTO}$(lista_sponda destra)${RESET}"
        echo -e "${MAGENTA}||=========================||${RESET}"
        echo
    }
    altra_sponda(){
        if [ "$1" = "sinistra" ]; then
            echo "destra"
        else
            echo "sinistra"
        fi
    }
    ferma_processo(){
        attore="$1"
        sponda="$2"
        container=$(container_sponda "$sponda")

        docker exec "$container" bash -c "if [ -f /tmp/$attore.pid ]; then kill \$(cat /tmp/$attore.pid) 2>/dev/null; rm -f /tmp/$attore.pid; fi"
    }
    start_process(){
        attore="$1"
        sponda=$(verifica_posizione "$attore")
        container=$(container_sponda "$sponda")

        docker exec "$container" bash -c "nohup bash -c 'exec -a $attore sleep infinity' >/dev/null 2>&1 & echo \$! > /tmp/$attore.pid"
    }
    verifica_input() {
        case "$1" in
            ""|l|L|p|P|c|C) 
            return 0
            ;;
            *)
            return 1
            ;;
        esac
    }
    sposta_attore(){
        attore="$1"

        sponda_origine=$(verifica_posizione "$attore")
        sponda_fine=$(altra_sponda "$sponda_origine")

        ferma_processo "$attore" "$sponda_origine"
        modifica_posizione "$attore" "$sponda_fine"
        start_process "$attore"
    }
    container_sponda(){
        if [ "$1" = "sinistra" ]; then
            echo "$SPO_SX"
        else
            echo "$SPO_DX"
        fi
    }
    modifica_posizione(){
        case "$1" in
            A|a) A="$2"
            ;;
            L|l) L="$2"
            ;;
            P|p) P="$2"
            ;;
            C|c) C="$2"
            ;;
        esac
    }
    contiene(){
        attore="$1"
        sponda="$2"

        [ "$(verifica_posizione "$attore")" = "$sponda" ]
    }
    verifica_lost(){
        for sponda in sinistra destra; do
            if ! contiene A "$sponda"; then
                if contiene L "$sponda" && contiene P "$sponda"; then
                    echo -e "${ROSSO}${GRASSETTO}"
                    echo "╔══════════════════════════════════════════════╗"
                    echo "║                  GAME OVER                   ║"
                    echo "╚══════════════════════════════════════════════╝"
                    echo -e "Il lupo ha divorato la pecora sulla sponda $sponda mentre l'Allevatore era assente!"
                    echo -e "${RESET}"
                    exit 1
                fi
                if contiene P "$sponda" && contiene C "$sponda"; then
                    echo -e "${ROSSO}${GRASSETTO}"
                    echo "╔══════════════════════════════════════════════╗"
                    echo "║                  GAME OVER                   ║"
                    echo "╚══════════════════════════════════════════════╝"
                    echo -e "La pecora ha ingurgitato il cavolo sulla sponda $sponda mentre l'Allevatore era assente!"
                    echo -e "${RESET}"
                    exit 1
                fi
            fi
        done
    }
    verifica_vict(){
        if [ "$A" = "destra" ] && [ "$L" = "destra" ] && [ "$P" = "destra" ] && [ "$C" = "destra" ]; then
            mostra_stato
            echo -e "${VERDE}${GRASSETTO}"
            
            echo "╔══════════════════════════════════════════════╗"
            echo -e "║           CONGRATULAZIONI DEV-OPS            ║"
            echo "║                  HAI VINTO!                  ║"
            echo "╚══════════════════════════════════════════════╝"
            echo -e "Hai permesso all'Allevatore di attraversare il fiume con tutti i suoi item!!"
            echo -e "${RESET}"
            exit 0
        fi

    }



#####inizio programma
inizializza_container

while true; do
    echo -e "${GRASSETTO}${MAGENTA}"
    echo -e "||=========================||"
    echo -e "||${RESET}    ${GRASSETTO}${GIALLO}BENVENUTO DEV-OPS${RESET}    ${GRASSETTO}${MAGENTA}||"
    echo -e "||                         ||${RESET}"
    mostra_stato
    echo -e "${GRASSETTO}${VERDE}L/l ${RESET}= Lupo 🐺"
    echo -e "${GRASSETTO}${VERDE}P/p ${RESET}= Pecora 🐑"
    echo -e "${GRASSETTO}${VERDE}C/c ${RESET}= Cavolo 🥬"
    echo -e "${GRASSETTO}${VERDE}INVIO ${RESET}= Allevatore 👨‍🌾"
    echo -e "${GRASSETTO}${ROSSO}Q/q ${RESET}= Quit 🔚"
    echo ""
    echo -n "Chi vuoi portare sulla barca con l'Allevatore? "

    read -r scelta

    if [ "$scelta" = "q" ] || [ "$scelta" = "Q" ]; then
        echo -e "${GRASSETTO}${VERDE}Arrivederci DEV-OPS!${RESET}"
        exit 0
    fi

    if ! verifica_input "$scelta"; then
        echo -e "${ROSSO}${GRASSETTO}Errore: scelta non valida!!"
        echo -e "Inserisci un attore valido!!${RESET}"
        sleep 3
        continue
    fi

    if [ -n "$scelta" ] && [ "$(verifica_posizione "$scelta")" != "$A" ];then
        echo
        echo -e "${GIALLO}Attenzione: $scelta non si trova sulla stessa sponda dell'Allevatore!!"
        echo -e "Riprova muovendo uno degli attori sulla sponda dell'Allevatore solo l'Allevatore!!${RESET}"
        sleep 3
        continue
    fi

    sposta_attore A

    if [ -n "$scelta" ]; then
        sposta_attore "$scelta"
    fi
    verifica_lost
    verifica_vict
done
