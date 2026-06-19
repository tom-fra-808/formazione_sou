#!/usr/bin/env bash
###################


#funzione checkfile per controllare se viene inserito un file valido o no
#creo funzione checkfile
checkfile (){ 
	#se non viene passato un argomento alla funzione verrà stampato "Inserisci un file" per via della flag -z di test
if [[ -z "$1" ]]; then   
	echo "Inserisci il nome di un file"
	return 1
fi

#verifica se l' argomento passato è un file regolare ed esistente grazie alla flag -f di test
if [[ ! -f "$1" ]]; then 
	echo "File non esistente"
	#se la condizione dell' if è vera il codice restituisce errore
	return 1
fi
#verifica se il file è vuoto grazie alla flag -s di test
if [[ ! -s "$1" ]]; then 
	echo "Il file esiste ma è vuoto :("
	#se la condizione dell' if è vera il codice restituisce errore
	return 1
fi
return 0
} #fine funzione

#inizio programma viene stampata una simpatica "etichetta" di presentazione del programma
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
#inizio di un ciclo while per rendere possibile l' analisi di più file in successione senza riaprire il programma
while true;do  
	
	#il comando read richiede un input del percorso del file da analizzare dall' utente e lo salva nella variabile $path. La flag -p rende possibile la stampa a schermo del testo di read
	read -p  "Inserire path del file da analizzare: " path  

	#si richiama la funzione checkfile per controllare il percorso inserito dall'utente; se il controllo fallisce || continue rimanda all' inizio del ciclo while; se il controllo è positivo e il file esiste e non è vuoto il programma continua
	checkfile "$path" || continue
	#viene stampato un piccolo caricamento falso 
	#viene stampata una riga vuota
	echo ""
	#si stampa "analizzo file" e con -n la prossima stringa viene stampata sulla riga precedente
	echo -n "Analizzo file $path "
	#vengono stamati dei puntini per simulare un caricamento con un intervallo di 1 sec grazie a sleep 1
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

	#il comando vero e proprio
	#sort riordina il file mettendo di fila gli stessi indirizzi--> uniq -c aggiunge all' inizio una colonna con il numero di ripetizioni della stessa stringa -->
	#sort -n li riordina in modo numerico dal più piccolo al più grande e -r reversa quindi dal più grande al più piccolo; -k1 ordina secondo la prima colonna e -k2 ordina a parità della prima colonna secondo la seconda
	#head -3 prende in considerazione solo le prime 3 righe
	sort "$path" | uniq -c | sort -nr -k1 -k2 | head -3
	echo ""
	#salvare i dati in un eventuale file. 
	read -r -p "Desideri salvare i dati in un file? (s/n): " scelta

	#se l'utente ha deciso di salvare il file gli si chiede di inserire un nome e una destinazione
	if [[ $scelta == "s" ]];then
		#nome salvato in variabile nf
		read -r -p "Nome del file: " nf
		#destinazione salvata in variabile dest
		read -r -p "Destinazione: " dest
		
		#verifica che la cartella di destinazione esista con la flag -d
		if [[ ! -d "$dest" ]]; then
			echo "Destinazione non esistente"
			continue
		fi
		
		#opzione eventuale per salvare pèiù righe invece di solo le ultime tre
		read -r -p "Quante righe vuoi salvare nel file?: " kk	
		
		#verifica che sia stato inserito un valore numerico e non altri caratteri
		if [[ ! "$kk" =~ ^[0-9]+$ ]]; then
			echo "Iserisci un numero!!"
			continue
		fi

		#salva il numero di righe selezionate nel file selezionato
		sort "$path" | uniq -c | sort -nr -k1 -k2 | head -n "$kk" >> "$dest/$nf"

		echo "! Dati salvati con successo in $dest/$nf !"

	elif [[ "$scelta" == "n" ]]; then
		echo ""
	else
		echo "Scelta non valida"
		continue
	fi

	#ciclo while per scegliere se continuare ad analizzare un nuovo file
	while true; do

		read -r -p "Desideri analizzare un altro file? (s/n): " ris

		if [[ $ris == "s" ]]; then
			echo ""
			break
		elif [[ $ris == "n" ]]; then
			echo "========================="
			echo "|                       |"
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
