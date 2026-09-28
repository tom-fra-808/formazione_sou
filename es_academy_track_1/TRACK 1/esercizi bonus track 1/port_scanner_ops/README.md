<h1 align="center">PORT-SCANNER-OPS</h1>

<h2 align="center">UTILIZZO</h2>

Il programma "_Port-Scanner-Ops_" analizza grazie al comando ```Netcat``` le porte aperte e chiuse in un host desiderato raggiungibile tramite la rete.

Il comando Netcat ```nc``` utilizza di base il proctocollo TCP per provare una connessione alle porte desiderate e determinarne lo stato.
### TCP vs UDP
TCP e UDP sono i due protocolli principali del livello trasporto e differiscono principalmente per affidabilità, modalità di trasporto, velocità e campo di utilizzo.

TCP prima di iniziare a trasmettere i dati effettua un three-way handshake con il destinatario.

Inizialmente il mittente invia un segmento con flag SYN a cui il destinario, se disponibile, risponde con un SYN-ACK e infine il mittente chiude l'handshake con un ACK, ed in successione viene aperta la connessione.

L'UDP invece non effettua questo tipo di verifiche, non garantisce consegna né ordine né ritrasmissione di dati persi.

#### _IL FLAG RST (reset)_
Il flag RST appartiene esclusivamente al protocollo TCP.
Qualora un destinatario ricevesse un segmento SYN su una porta TCP chiusa risponderebbe con un segmento contenente il flag "RST", ovvero reset. La ricezione di un pacchetto RST indica che il destinatario è raggiungibile ma la porta interrogata non ha un servizio in ascolto.

## _Struttura del Programma_
1. Definizione funzioni di controllo e variabili
2. Input IPv4 + Range porte 
3. Inizio programma
4. Applicazione funzioni di controllo
5. Controllo connettività con host
6. Creazione file temporanei
7. Port-scan
8. Eventuale salvataggio dati
9. Chiusura programma

## _1 - Definizione funzioni e variabili_
### function _CHECK_IP_
Funzione che controlla la validità di un indirizzo IPv4 tramite regex.
```bash
check_ip(){
	local ip="$1"
	if [[ ! "$ip" =~ ^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]?[0-9])$ ]]; then
		echo "Indirizzo '$ip' inserito non valido."
		echo "Si prega di inserire un indirizzo valido."
		return 1
	fi
}
```
### function _CHECK_PORTE_
Funzione che controlla la validità del valore inserito per le porte che può variare tra 1-65535.
```bash
check_porte(){
	local port="$1"
	if  [[ ! "$port" =~ ^[0-9]+$ ]] || (( $port < 1 || $port > 65535 )); then			return 1
	fi
}
```
### function _CHECK_CONNECTION_
Funzione che verifica se l'host da controllare risponde a pacchetti echo.
Si usa il comando ```nmap``` con la flag ```-sn``` che verifica solo che l'host esista e sia online tramite un pacchetto EchoRequest (flag ```-PE```) che determina se l'host è online qualora ricevesse una EchoReply.
```LC_ALL=C``` fa sì che il comando successivo venga eseguito con la lingua e le regole standard unix ignorando le impostazioni locali e in questo modo ```grep``` è sicuro di cercare nella lingua corretta.
```bash
check_connection(){
	local host="$1"
	if LC_ALL=C nmap -sn -n -PE "$host" 2>/dev/null | grep -q "Host is up"; then
		return 0
	else
		return 1
	fi
}
```
### _Costrutto "if" per verificare che gli argomenti siano stati inseriti nel giusto modo_
Costrutto che ferma il prgoramma qualora l'utente abbia inserito più o meno di tre argomenti e stampa un esempio di utilizzo del programma.
```bash

	if (( $# != 3 )); then
		echo "Il programma $0 necessita 3 argomenti: [ind.ip] [porta d'inizio scan] [porta di fine scan]."
		echo "ex. '$0 192.168.10.10 200 23000'"
		exit 1
	fi
```
### _Definizione variabili_
```bash
	ip=$1
	ini_port=$2
	fini_port=$3
```

## _2 - Input indirizzo IPv4 e range porte_
L'utente per avviare il programma senza errori dovrà usare questa formattazione.
```bash
./portscanner.sh <ind. IPv4> <porta inizio scan> <porta fine scan>
```

## _3 - Inizio Programma_
```bash
#INIZIO PROGRAMMA (BANNER)
	echo "==============================="
	echo "|     Benvenuto/a Dev-Ops     |"
	echo "|      DEV    ===    OPS      |"
	echo "!--------------|--------------!"
	echo "|      PORT-SCANNER-OPS!      |"
	echo "|=============================|"
	echo 
	sleep 1
```
## _4 - Applicazione Funzioni Di Controllo_
### Controllo Indirizzo Ip
```bash
	if check_ip "$ip"; then
		echo 
		echo "Indirizzo inserito '$ip' è corretto"
		sleep 0.2
	else
		exit 1
	fi
```
### Controllo Porte
In questo passaggio il programma verifica che il numero di porta sia nel range valido e permette, qualora l'utente mettesse lo stesso numero di porta due volte, di analizzare una sola porta.
```bash
	if check_porte "$ini_port"; then
		echo "Porta di inizio scan valida: '$ini_port'."
		sleep 0.2
	else
		echo "Porta di inizio scan non valida: '$ini_port'. {range (1-65535)}"
		exit 1
	fi
	if check_porte "$fini_port"; then
		echo "Porta di fine scan valida: '$fini_port'."
		sleep 0.2
	else
		echo "Porta di fine scan non valida: '$fini_port'. {range (1-65535)}"
		exit 1
	fi

	if (( $ini_port > $fini_port )); then
		echo "Inserire per primo il valore più piccolo"
		exit 1
	elif (( $ini_port == $fini_port )); then
		while true; do
			echo "Hai inserito la stessa porta due volte; vuoi continuare lo stesso? (s/n)"
			read ris
			if [[ "$ris" == "n" ]]; then
				echo "Riproviamoci!"
				exit 1
			elif [[ "$ris" == "s" ]]; then
				echo "Ok, analizzerò solo una porta."
				sleep 0.5
				break
			else
				echo "Inserire valore corretto."
			fi		
		done
	fi

```

## _5 - Controllo Connettività Con Host_
```bash
	echo -n "Controllo se l'host $ip è raggiungibile"
	sleep 0.5
	echo -n "."
	sleep 0.5
	echo -n "."
	sleep 0.5
	echo "."
	sleep 0.5
	if check_connection "$ip"; then
		echo "Host $ip raggiungibile"
	else
		echo "Host $ip non raggiungibile o filtrato."
		exit 1
	fi
	#finto loading
	echo
	echo -n "Analizzo "
	sleep 0.5
	echo -n "."
	sleep 0.5
	echo -n "."
	sleep 0.5
	echo -n "."
	sleep 0.5
	echo "."
	sleep 0.5
	echo
```
## _6 - Creazione File Temporanei_
Vengono creati due file temporanei, uno per le porte aperte e uno per le porte chiuse.
```bash
	echo "====PORTE CHIUSE====" > /tmp/closed_$ip.txt
	echo "====PORTE APERTE====" > /tmp/open_$ip.txt
```

## _7 - Port-Scan_
Viene usato un ciclo "for" con il comando 'netcat' con le flags -z e -w. La flag -z permette di verificare se la porta è aperta o chiusa senza che venga effettuato uno scambio di dati; la flag -w per dare uhn timeout a nc così che non rimanga bloccato per troppo tempo su una stessa porta.
```bash
	for (( i=ini_port; i<=fini_port; i++ )); do
		if nc -z -w 1 "$ip" "$i" >/dev/null 2>&1; then
			echo "Porta $i aperta"
			echo "Porta $i" >> /tmp/open_$ip.txt
		else
			echo "Porta $i chiusa o non raggiungibile"
			echo "Porta $i" >> /tmp/closed_$ip.txt
		fi
	done
```
## _8 - Salvataggio Dati_
In questo passaggio viene chiesto all'utente se vuole salvare i dati appena ricavati in un file in una destinazione a sua scelta.
```bash
	echo 
	while true; do
		read -r -p "Desideri salvare i dati in un file? (s/n): " scelta
	    if [[ $scelta == "s" ]];then
                    read -r -p "Nome del file: " nf
                    read -r -p "Destinazione: " dest
                    read -r -p "Nome Hostname: " Hostname
                
                if [[ -z "$nf" ]]; then
                    echo "Nome file non valido"
                    continue
                fi		

                if [[ ! -d "$dest" ]]; then
                    echo "Destinazione non esistente"
                    continue
                fi

                if [[ ! -w "$dest" ]]; then
                    echo "Non hai permessi di scrittura in questa destinazione"
                    continue
                fi
                echo "Hostname: $Hostname" > "$dest/$nf"
                echo "Ip: $ip" >> "$dest/$nf"
                date >> "$dest/$nf"
                echo >> "$dest/$nf"
                cat /tmp/open_$ip.txt >> "$dest/$nf"
                echo >> "$dest/$nf"
                cat /tmp/closed_$ip.txt >> "$dest/$nf"

                echo "! Dati salvati con successo in $dest/$nf !"
                break

		elif [[ $scelta == n ]]; then
				echo ""
				break
		else
				echo "Scelta non valida"
				continue
			fi
		done

		rm -f /tmp/open_$ip.txt
		rm -f /tmp/closed_$ip.txt
```

## _9 - Chiusura Programma_
```bash
	echo "|======================|"
	echo "| Grazie e arrivederci |"
	echo "|                      |"
	echo "|    DEVOPS--TRIBE     |"
	echo "\======================/"
	echo " \                    / "
	echo "  \ PORT-SCANNER-OPS / "
	echo "   \================/  "
```
