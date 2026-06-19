#!/usr/bin/env bash

#while + read processare file riga per riga


#array 
#somma totale cpu x ogni server


#numero di occorrenze di ogni server nel file

#calcolo output --> media matematica dell' utilizzo cpu

#!/bin/bash

FILE_INPUT="metriche.txt"

# Controllo se il file esiste
if [[ ! -f "$FILE_INPUT" ]]; then
    echo "Errore: il file $FILE_INPUT non esiste."
    exit 1
fi

# Controllo se il file è vuoto
if [[ ! -s "$FILE_INPUT" ]]; then
    echo "Errore: il file $FILE_INPUT è vuoto."
    exit 1
fi

# Array associativi
declare -A somma_cpu
declare -A occorrenze

# Array normale per ricordare l'ordine dei server trovati
server_unici=()

# Lettura del file riga per riga
while read -r server cpu; do

    # Se è la prima volta che incontro questo server,
    # lo aggiungo alla lista dei server unici
    if [[ -z "${occorrenze[$server]}" ]]; then
        server_unici+=("$server")
        somma_cpu[$server]=0
        occorrenze[$server]=0
    fi

    # Sommo il valore CPU al totale di quel server
    somma_cpu[$server]=$(( somma_cpu[$server] + cpu ))

    # Aumento di 1 il numero di volte in cui quel server compare
    occorrenze[$server]=$(( occorrenze[$server] + 1 ))

done < "$FILE_INPUT"

echo "=== REPORT UTILIZZO MEDIO CPU ==="

# Ciclo sui server unici trovati
for server in "${server_unici[@]}"; do
    media=$(( somma_cpu[$server] / occorrenze[$server] ))
    echo "$server: $media%"
done

