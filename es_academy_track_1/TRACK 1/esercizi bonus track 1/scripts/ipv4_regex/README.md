<h1 align="center">IPpassport-v4</h1>

## Progettazione
Il programma "__IPpassport-v4__" chiede all'utente di inserire un indirizzo IPv4.

Appena inserito, l'IP viene controllato dalla funzione **_check_ip_** che verifica se è un ip valido e, qualora non rispetti le condizioni, stampa un messaggio di errore e ritorna alla richiesta iniziale.

Successivamente, se il controllo è stato positivo e l'utente conferma di aver inserito l'ip corretto, l'ip passa nella funzione **_class_ip_** che grazie alle regex identifica la classe e/o se è un indirizzo speciale e lo stampa a schermo.

Avvenuto questo passaggio il programma chiede se si vuole analizzare un nuovo indirizzo. In caso di risposta negativa il programma si arresta.

## Tabella Classificazione Indirizzi
| Tipologia | Prefisso | Intervallo | Classe | Utilizzo |
|---|---|---|---|---|
| `This network`| 0.0.0.0/8 | 0.0.0.0 – 0.255.255.255 | Riservato | "This network" |
| `Non specificato` | 0.0.0.0/32 | 0.0.0.0 | Riservato | Indirizzo non specificato |
| `Privato` | 10.0.0.0/8 | 10.0.0.0 – 10.255.255.255 | A | Reti private |
| `Shared CGN` | 100.64.0.0/10 | 100.64.0.0 – 100.127.255.255 | A | Carrier-Grade NAT degli operatori |
| `Loopback` | 127.0.0.0/8 | 127.0.0.0 – 127.255.255.255 | A riservata | Loopback |
| `Link-local/APIPA` | 169.254.0.0/16 | 169.254.0.0 – 169.254.255.255 | B | Link-local/APIPA
| `Privato` | 172.16.0.0/12 | 172.16.0.0 – 172.31.255.255 | B | Reti private |
| `Privato` | 192.168.0.0/16 | 192.168.0.0 – 192.168.255.255 | C | Reti private |
| `Multicast` | 224.0.0.0/4 | 224.0.0.0 – 239.255.255.255 | D | Comunicazione multicast |
| `Riservato` | 240.0.0.0/4 | 240.0.0.0 – 255.255.255.255 | E | Spazio riservato per usi futuri|
| `Broadcast limitato` | 255.255.255.255/32 | 255.255.255.255 | Eccezione nella E | Tutti gli host della rete locale |

## Codice
### Setting Colori
Imposto delle variabili con i codici di colori e grassetto per sfondo e caratteri.
```bash
SFONDO_ROSSO="\033[41m" #sfondo rosso
ROSSO="\033[31m" #x errori
VERDE="\033[32m" #x successo
GIALLO="\033[33m" #per classi
MAGENTA="\033[35m" #x indirizzi
CIANO="\033[36m" #x info sis
GRASSETTO="\033[1m" #x info 
RESET="\033[0m"
```
### Funzione Controllo IPv4
Tramite regex la funzione controlla la validità dell' indirizzo inserito dall'utente.

```bash
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
```

### Funzione riconoscimento classe IPv4
Con condizioni if controllo l'indrizzo a quale classe e/o categoria speciale appartiene.
```bash
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
```

### Inizio Programma
Viene utilizzato un ciclo while infinito per analizzare, a discrezione dell'utente, più indirizzi di fila.
```bash
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
```


## Differenza tra regex basic e estese
La principale differenza tra i due tipi di regex è il modo in cui interpretano i caratteri speciali. Se per le basic bisogna inserire un backslash per permettergli di interpretare dei caratteri speciali per le extended questo non serve.
Inoltre il comando grep usa solo Basic mentre egrep ( o grep -E ) lavora con le Extended.
#### Sintassi Regex estese utilizzate
| Simbolo | Significato | Esempio |
|---|---|---|
| `^` | Indica l'inizio della stringa | `^127\.` |
| `$` | Indica la fine della stringa | `...$` |
| `.` | Rappresenta qualsiasi carattere | `a.b` |
| `\.` | Rappresenta un punto letterale senza che venga interpretato come qualsiasi carattere | `127\.` |
| `()` | Raggruppa più elementi della regex | `(25[0-5]\|2[0-4][0-9])` |
| `\|` | Indica una condizione "or" | `25[0-5]\|2[0-4][0-9]` |
| `[0-9]` | Rappresenta una cifra compresa tra 0 e 9 | `[0-9]` |
| `?` | L'elemento precedente può ripetersi dalle 0 alle 1 volte | `[1-9]?` |
| `{x}` | Ripete l'elemento precedente esattamente x volte | `(...\.){x}` |
