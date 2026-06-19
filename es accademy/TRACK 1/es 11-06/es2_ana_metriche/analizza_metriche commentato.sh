#!/usr/bin/env bash

# il codice si divide in tre parti (quattro con il checkfile)
# 0 - input file e controllo validità
# 1 - creazione array e calcolo media
# 2 - richiesta di salvataggio file
# 3 - richiesta di analisi nuovo file
#
# All' inizio viene stabilita una funzione checkfile usata anche nell' esercizio precedente
# La logica per l' esercizio è che il programma, dopo aver creato gli array e dopo aver controllato
#che il file sia un file valido con "checkfile", legge il file e inizia ad aggiungere agli array i
#valori indicati nelle funzioni matematiche. Dopodiché stampa il risultato. Qui chiede all' utente
#se desidera salvare il file e quante righe di questo eventualmente. Successivamente chiede se
#l'utente desidera analizzare un sltro file. In caso negativo saluta e si chiude.



#funzione checkfile presa da es1
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
#creazione di due array associativi (uno per la soma di cpu e uno per il conto di apparizioni per calcolare la media)
declare -A somma_cpu
declare -A apparizioni

#stampa inizio programma e benvenuto
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

#ciclo while per evitare l'uscita dopo eventuali misclick o errori di inserimento
while true;do
	#richiede input file dall'utente
	read -r -p "Inserisci il nome del file: " file
	#richiama la funzione checkfile per controllare se file esiste ed è regolare; in caso contrario ritorna al read
	checkfile "$file" || continue

	#dichiaro gli array vuoti 
	somma_cpu=()
	apparizioni=()

	#ciclo while che permette di leggere da un file di input due valori: server(nome) e cpu
	while read -r server cpu; do

		#espressione per aumentare il valore dell' array riguardante la cpu di ogni server (key)
		#se il server non è già presente nell' array prende come valore 0
		somma_cpu[$server]=$(( ${somma_cpu[$server]:-0} + cpu ))

		#espressione per aumentare il valore delle apparizioni nell' array
		#se il server non è presente prende 0 come valore
		apparizioni[$server]=$(( ${apparizioni[$server]:-0} + 1 ))

		#prende input file
	done < "$file"

	#creo la variabile report che contiene il blocco comandi che calcola la media cpu/apparizioni
	report=$(
		#ciclo for per analizzare ogni server nell' array
		#"!" indica le chiavi totali dell' array
		for server in "${!somma_cpu[@]}"; do
			# ""media=$(( somma_cpu[$server] / apparizioni[$server] ))"" per calcolare la media arrotondata per difetto all' intero più vicino
			#utilizzo invece awk che permette di calcolare anche parte decimale
			#creo la variabile media usando awk. -v dichiara una varibile ad awk, con begin gli dico di eseguire il calcolo (somma / app) e con printf %.2f di stampare il risultato con due "figures" decimali
			media=$(awk -v somma="${somma_cpu[$server]}" -v app="${apparizioni[$server]}" 'BEGIN { printf "%.2f", somma / app }')
			#per ogni server stampa " | nome : valore media "
			echo "| $server: $media%"
			#chiude il ciclo for e passa l'output a sort che riorganizza in ordine numerico decrescente (-n -r) il secondo campo ( -k2 ) che identifica tramite il separatore (:) grazie alla flag -t
		done | sort -t ":" -k2,2nr
	) #fine blocco

	#stampa il report utilizzo cpu richiamando variabile report
	echo ""
	echo "=== REPORT UTILIZZO MEDIO CPU ==="
	echo "---------------------------------"
	echo "$report"
	echo "---------------------------------"

	#apro ciclo while per chiedere se si desidera salvare i log
	#ho pensato fosse una cosa utile in questi casi
	while true; do
		#legge input scelta
		read -r -p "Desideri salvare i dati in un file? (s/n): " scelta

		#se scelta postiva chiede nome file e destinazione
		if [[ "$scelta" == "s" ]];then
		read -r -p "Nome del file: " nf
		read -r -p "Destinazione: " dest
			
		#controllo destinazione
			#-z se campo nome lasciato vuoto
			if [[ -z "$nf" ]]; then
				echo "Nome file non valido"
				continue
			fi		

			#-d se destinazione esiste
			if [[ ! -d "$dest" ]]; then
				echo "Destinazione non esistente"
				continue
			fi

			#-w se utente ha permessi per scrivere nella cartella
			if [[ ! -w "$dest" ]]; then
				echo "Non hai permessi di scrittura in questa destinazione"
				continue
			fi
			
			#chiede quante righe del file vuole che vengano salvate in caso ci sianoc più server da analizzare
			read -r -p "Quante righe vuoi salvare nel file?: " kk	
			
			#controlla che sia stato inserito un numero
			if [[ ! "$kk" =~ ^[0-9]+$ ]]; then
				echo "Iserisci un numero!!"
				continue
			fi

			#salvo il file con le righe scelte nella destinazione scelta
			{
			echo "=== REPORT UTILIZZO MEDIO CPU ==="
			echo ""
			echo "$report" | head -n "$kk"
			} > "$dest/$nf"

			echo "! Dati salvati con successo in $dest/$nf !"
			break

		#se utente non vuole salvare esco dal ciclo while
		elif [[ "$scelta" == "n" ]]; then
			echo ""
			break
		#se utente sbaglia torno alla richiesta
		else
			echo "Scelta non valida"
			continue
		fi
	done

	#chiedo se utente vuole analizzare un altro file
	while true; do
		sleep 0.2 #un minimo di pausa
		read -r -p "Desideri analizzare un altro file? (s/n): " ris

		if [[ "$ris" == "s" ]]; then
			echo ""
			break
		elif [[ "$ris" == "n" ]]; then
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

