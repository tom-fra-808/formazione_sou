#!/usr/bin/env bash
checkfile (){ 
if [[ -z "$1" ]]; then   
	echo "! Inserisci il nome di un file !"
	return 1
fi

if [[ ! -f "$1" ]]; then 
	echo "! File non esistente !"
	return 1
fi

if [[ ! -s "$1" ]]; then 
	echo "! Il file esiste ma è vuoto :( !"
	return 1
fi

return 0
} 

declare -A somma_cpu
declare -A apparizioni

echo "###########################################"
echo "#                                         #"
echo "#   Benvenut* nel programma di analisi    #"
echo "#                                         #"
echo "#            log cpu server per           #"
echo "#                                         #"
echo "#                  DEVOPS                 #"
echo "#                                         #"
echo "###########################################"
echo ""

while true;do
	read -r -p "Inserisci il nome del file: " file
	checkfile "$file" || continue

	somma_cpu=()
	apparizioni=()

	while read -r server cpu; do

		somma_cpu[$server]=$(( ${somma_cpu[$server]:-0} + cpu ))

		apparizioni[$server]=$(( ${apparizioni[$server]:-0} + 1 ))


	done < "$file"

	report=$(
		for server in "${!somma_cpu[@]}"; do
			#media=$(( somma_cpu[$server] / apparizioni[$server] ))
			media=$(awk -v somma="${somma_cpu[$server]}" -v num="${apparizioni[$server]}" 'BEGIN { printf "%.2f", somma / num }')
			echo "| $server: $media%"
		done | sort -t ":" -k2,2nr
	)

	echo ""
	echo "=== REPORT UTILIZZO MEDIO CPU ==="
	echo "---------------------------------"
	echo "$report"
	echo "---------------------------------"

	while true; do
		read -r -p "Desideri salvare i dati in un file? (s/n): " scelta

		if [[ $scelta == "s" ]];then
		read -r -p "Nome del file: " nf
		read -r -p "Destinazione: " dest
		
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
		
			read -r -p "Quante righe vuoi salvare nel file?: " kk	
		
			if [[ ! "$kk" =~ ^[0-9]+$ ]]; then
				echo "Iserisci un numero!!"
				continue
			fi

			{
			echo "=== REPORT UTILIZZO MEDIO CPU ==="
			echo ""
			echo "$report" | head -n "$kk"
			} > "$dest/$nf"

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

	while true; do
		sleep 0.2
		read -r -p "Desideri analizzare un altro file? (s/n): " ris

		if [[ $ris == "s" ]]; then
			echo ""
			break
		elif [[ $ris == "n" ]]; then
			echo "========================="
			echo "|       Arrivederci     |"
			echo "========= DEVOPS ========"
			echo ""
			exit 0
		else
			echo "Non ho capito!"
			echo ":("
			echo ""
		fi
	done
done

