#!/usr/bin/env bash
SFONDO_ROSSO="\033[41m" #sfondo rosso
ROSSO="\033[31m" #x errori
VERDE="\033[32m" #x successo
GIALLO="\033[33m" #per classi
MAGENTA="\033[35m" #x indirizzi
CIANO="\033[36m" #x info sis
GRASSETTO="\033[1m" #x info 
RESET="\033[0m"
check_ip(){
    local ip="$1"
    if [[ ! "$ip" =~ ^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ ]]; then
		echo -e "${GRASSETTO}${ROSSO}Indirizzo${RESET} ${MAGENTA}'$ip'${RESET} ${GRASSETTO}${ROSSO}inserito non valido.${RESET}"
		echo -e "${GRASSETTO}${ROSSO}Si prega di inserire un indirizzo IPv4 valido.${RESET}"
        echo -e "${GRASSETTO}${ROSSO}Esempio: "12.34.56.78" (usa i punti come separatori e non lasciare spazi)${RESET}"
        echo -e "${GRASSETTO}${ROSSO}[Inserire numeri in range 0-255]${RESET}"

		return 1
	fi
    return 0
}
class_ip(){
        local ip="$1"
        if [[ "$ip" =~ ^0\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ ]]; then
            if [[ "$ip" == 0.0.0.0 ]]; then
                echo -e "Indirizzo ${MAGENTA}'$ip'${RESET} ${GIALLO}'Non specificato'${RESET}." 
            else
                echo -e "Indirizzo ${MAGENTA}'$ip'${RESET} appartenente allo spazio riservato ${GIALLO}'This network'${RESET}."
            fi
		    return 0
        elif [[ "$ip" =~ ^(12[0-7]|1[0-1][0-9]|[1-9][0-9]|[1-9])\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ ]]; then
            if [[ "$ip" =~ ^127\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ ]]; then
                echo -e "Indirizzo ${MAGENTA}'$ip'${RESET} riservato al ${VERDE}${GRASSETTO}'Loopback'${RESET}."
            elif [[ "$ip" =~ ^100\.(12[0-7]|1[0-1][0-9]|[7-9][0-9]|6[4-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ ]]; then
                echo -e "Indirizzo ${MAGENTA}'$ip'${RESET} appartenente alla ${GIALLO}'Classe A'${RESET}."
                echo -e "Indirizzo ${GRASSETTO}${VERDE}'Carrier-Grade NAT'${RESET}."
            elif [[ "$ip" =~ ^10\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ ]]; then
                echo -e "Indirizzo ${MAGENTA}'$ip'${RESET} appartenente alla ${GIALLO}'Classe A'${RESET}."
                echo -e "Indirizzo ${GRASSETTO}${VERDE}Privato${RESET}."
            else
                 echo -e "Indirizzo ${MAGENTA}'$ip'${RESET} appartenente alla ${GIALLO}'Classe A'${RESET}."
                 echo -e "Indirizzo ${GRASSETTO}${VERDE}Pubblico${RESET}."
 
            fi
            if [[ "$ip" == 8.8.8.8 ]]; then
                echo "Questo è proprio il DNS di Gooooooogle!!"
            fi
		    return 0

        elif [[ "$ip" =~ ^(12[8-9]|1[3-8][0-9]|19[0-1])\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ ]]; then
                echo -e "Indirizzo ${MAGENTA}'$ip'${RESET} appartenente alla ${GIALLO}'Classe B'${RESET}."
            if [[ "$ip" =~ ^169\.254\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ ]]; then
                echo -e "Indirizzo ${GRASSETTO}${VERDE}'link-local/APIPA'${RESET}."
            elif [[ "$ip" =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ ]]; then
                echo -e "Indirizzo ${GRASSETTO}${VERDE}Privato${RESET}."
            else
                echo -e "Indirizzo ${GRASSETTO}${VERDE}Pubblico${RESET}."
            fi
		    return 0 
        elif [[ "$ip" =~ ^(19[2-9]|2[0-1][0-9]|22[0-3])\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ ]]; then
            echo -e "Indirizzo ${MAGENTA}'$ip'${RESET} appartenente alla ${GIALLO}'Classe C'${RESET}."
            if [[ "$ip" =~ ^(192)\.(168)\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ ]]; then
                echo -e "Indirizzo ${GRASSETTO}${VERDE}Privato${RESET}."
            else
                echo -e "Indirizzo ${GRASSETTO}${VERDE}Pubblico${RESET}."
            fi
		    return 0
        elif [[ "$ip" =~ ^(22[4-9]|23[0-9])\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ ]]; then
            echo -e "Indirizzo ${MAGENTA}'$ip'${RESET} appartenente alla ${GIALLO}'Classe D: indirizzi di multicasting'${RESET}."
		    return 0
        elif [[ "$ip" =~ ^(24[0-9]|25[0-5])\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ ]]; then
            if [[ "$ip" == "255.255.255.255" ]];then
                echo -e "Indirizzo di ${GRASSETTO}${VERDE}Broadcast limitato${RESET}." 
            else
                echo -e "Indirizzo ${MAGENTA}'$ip'${RESET} appartenente alla ${GIALLO}'Classe E: indirizzi sperimentali e per usi futuri'${RESET}."

            fi      
            return 0
	fi 
}
##################
#inizio programma
echo -e "${VERDE}${GRASSETTO}===============================================${RESET}"
echo -e "${VERDE}${GRASSETTO}${SFONDO_ROSSO}                IPpassport-v4                  ${RESET}"
echo -e "${VERDE}${GRASSETTO}===============================================${RESET}"
sleep 1
while true; do
    echo -e -n "${GRASSETTO}${CIANO}Inserisci il tuo ip:${RESET} "
    read -r ip
    echo -e "${VERDE}${GRASSETTO}===============================================${RESET}"
    if ! check_ip "$ip"; then
        echo
        continue
    fi
    while true; do
        echo -e -n "L' indirizzo ${MAGENTA}'$ip'${RESET} è ${GRASSETTO}${VERDE} corretto${RESET}? (s/n): "
        read -r sce
        echo -e "${VERDE}${GRASSETTO}===============================================${RESET}"
        case "${sce,,}" in
            s|si|yes|y)
                class_ip "$ip"
                echo "|"
                break
                ;;
            n|no)
                echo "Ok, riproviamo."
                echo
                continue 2
                ;;
            *)
                echo -e "${GRASSETTO}${ROSSO}Inserisci una risposta valida. (s/n)${RESET}"
                echo
                ;;
        esac
    done
    while true; do
        echo -e -n "${GRASSETTO}${CIANO}Vuoi controllare un altro indirizzo? (s/n)${RESET} "
        read -r ans
        echo "|"
        case "${ans,,}" in 
            s|yes|si|y)
                break
                ;;
            n|no)
                echo -e "${VERDE}${GRASSETTO}================================${RESET}"
                echo -e "${VERDE}${GRASSETTO}${SFONDO_ROSSO}      Arrivederci DEV-OPS       ${RESET}"
                echo -e "${VERDE}${GRASSETTO}================================${RESET}"
                exit 0
                ;;
            *)
                echo -e -n "${GRASSETTO}${ROSSO}Inserisci un valore corretto (s/n)${RESET} "
                sleep 1
                echo -n "."
                sleep 1
                echo "."
                ;;
        esac
    done
done

