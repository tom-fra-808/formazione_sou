#!/usr/bin/env bash
###################

#scelgo file



#controllo se file esiste e non è vuoto

checkfile (){
if [[ -z "$1" ]]; then
	echo "Inserisci il nome di un file"
	return 1
fi

if [[ ! -f "$1" ]]; then
	echo "File non esistente"
	return 1
fi
if [[ ! -s "$1" ]]; then
	echo "Il file esiste ma è vuoto :("
	return 1
fi
return 0
}
echo "###########################################"
echo "#                                         #"
echo "# Benvenut* nel programma di analisi file #"
echo "#                                         #"
echo "#                                         #"
echo "#                  DEVOPS                 #"
echo "#                                         #"
echo "#                                         #"
echo "###########################################"
echo ""
while true;do
	
	read -p  "Inserire path del file da analizzare: " path

	checkfile "$path" || continue
	echo ""
	echo -n "Analizzo file $path "
	echo -n "."
	sleep 1
	echo -n "."
	sleep 1
	echo -n "."
	sleep 1
	echo  "."
	sleep 1
	echo ""
	echo "Ecco i tre indirizzi più presenti! "
	echo ""
	sleep 0.5

	sort $path | uniq -c | sort -nr -k1 -k2 | head -3
	echo ""
	read -r -p "Desideri salvare i dati in un file? (s/n): " scelta

	if [[ $scelta == "s" ]];then
		read -r -p "Nome del file: " nf
		read -r -p "Destinazione: " dest
		
		if [[ ! -d "$dest" ]]; then
			echo "Destinazione non esistente"
			continue
		fi
		
		read -r -p "Quante righe vuoi salvare nel file?: " kk	
		
		if [[ ! "$kk" =~ ^[0-9]+$ ]]; then
			echo "Iserisci un numero!!"
			continue
		fi

		sort $path | uniq -c | sort -nr -k1 -k2 | head -n "$kk" >> "$dest/$nf"

		echo "! Dati salvati con successo in $dest/$nf !"

	elif [[ $scelta == n ]]; then
		echo ""
	else
		echo "Scelta non valida"
		continue
	fi

	while true; do
		echo""

		read -r -p "Desideri analizzare un altro file? (s/n): " ris

		if [[ $ris == "s" ]]; then
			echo ""
			break
		elif [[ $ris == "n" ]]; then
			echo ""
			echo "|  Chiudo il programma  |"
			echo "|      Arrivederci      |"
			echo "======== DEVOPS ========="
			exit 0
		else
			echo "Non ho capito!"
			echo ""
			echo ":("
		fi
		done

done
