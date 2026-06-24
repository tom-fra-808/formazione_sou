#!/usr/bin/env bash
#
#
#
while true
do
        #aggiungere utente e password
        read -p "Inserire nome nuovo utente: " name
        sudo useradd -m $name
        echo "Utente aggiunto"
        sudo passwd $name
        echo "Password aggiunta"
        while true
        do
                #parte del codice per scegliere se aggiungere più utenti
                read -p "Desideri aggiungere un nuovo utente? (s/n): " ans
                if [[ $ans == "s" ]]; then
                        break
                elif [[ $ans == "n" ]]; then
                        exit 0
                else
                        echo "Inserisci un valore valido (s/n): "
        fi
        done
done
~                                                                      