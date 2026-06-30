#!/usr/bin/env bash
###################
#definizione funzioni controllo e variabili
#input ip + porte range
#applicazione funzioni controllo
#controllo connettività host2host
#portscan
#eventuale salvataggio dati

#funzioni controllo
	check_ip(){
		local ip="$1"
		if [[ ! "$ip" =~ ^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]?[0-9])$ ]]; then
			echo "Indirizzo '$ip' inserito non valido."
			echo "Si prega di inserire un indirizzo valido."
			return 1
		fi
	}
	check_porte(){
		local port="$1"
		if  [[ ! "$port" =~ ^[0-9]+$ ]] || (( $port < 1 || $port > 65535 )); then
			return 1
		fi
	}
	check_connection(){
		local host="$1"
		if LC_ALL=C nmap -sn -PE "$host" 2>/dev/null | grep -q "Host is up"; then
			return 0
		else
			return 1
		fi
	}
	if (( $# != 3 )); then
		echo "Il programma $0 necessita 3 argomenti: [ind.ip] [porta d'inizio scan] [porta di fine scan]."
		echo "ex. '$0 192.168.10.10 200 23000'"
		exit 1
	fi

#definizione variabili
	ip=$1
	ini_port=$2
	fini_port=$3

#INIZIO PROGRAMMA (BANNER)
	echo "==============================="
	echo "|     Benvenuto/a Dev-Ops     |"
	echo "|      DEV    ===    OPS      |"
	echo "!--------------|--------------!"
	echo "|      PORT-SCANNER-OPS!      |"
	echo "|=============================|"
	echo 
	sleep 1
#controllo ip
	if check_ip "$ip"; then
			echo 
			echo "Indirizzo inserito '$ip' è corretto"
			sleep 0.2
		else
			exit 1
	fi
#controllo porte
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

#controllo connettività con host
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
#creazione file temporanei
	echo "====PORTE CHIUSE====" > /tmp/closed_$ip.txt
	echo "====PORTE APERTE====" > /tmp/open_$ip.txt

#portscan
	for (( i=ini_port; i<=fini_port; i++ )); do
		if nc -z -w 1 "$ip" "$i" >/dev/null 2>&1; then
			echo "Porta $i aperta"
			echo "Porta $i" >> /tmp/open_$ip.txt
		else
			echo "Porta $i chiusa o non raggiungibile"
			echo "Porta $i" >> /tmp/closed_$ip.txt
		fi
	done
#salvataggio dati
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
#chiusura programma
	echo "|======================|"
	echo "| Grazie e arrivederci |"
	echo "|                      |"
	echo "|    DEVOPS--TRIBE     |"
	echo "\======================/"
	echo " \                    / "
	echo "  \ PORT-SCANNER-OPS / "
	echo "   \================/  "