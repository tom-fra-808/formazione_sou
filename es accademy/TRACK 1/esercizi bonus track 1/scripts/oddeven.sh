#!/usr/bin/env bash
#oddeven

check_num() {
	local num="$1"
	if [[ ! "$num"  =~ ^[0-9]+$ ]]; then
		echo "Inserisci un solo valore corretto"
		return 1
	fi
}

check_odd(){
	local num="$1"
	if (( "$num" % 2 == 0 )); then
		echo "$num è pari"
	else
		echo "$num è dispari"
	fi
}

check_prime() {
    local numero="$1"
    local divisore

    if (( numero < 2 )); then
        echo "$numero non è primo"
        return 1
    fi

    for ((divisore = 2; divisore * divisore <= numero; divisore++)); do
        if (( numero % divisore == 0 )); then
            echo "$numero non è primo"
            return 1
        fi
    done

    echo "$numero è primo"
    return 0
}

while true;do
	read -r -p "Inserisci un solo numero (q per uscire): " n
	if [[ "$n" == q ]]; then
		echo "Addio!"
		break
	fi
	if ! check_num "$n"; then
		continue
	fi

	if (( "$n" == 0 )); then
		echo "Inserisci un valore diverso da 0!"
		continue
	fi

	for ((i=1; i<=$n; i++)); do
		check_odd "$i"

	done
		check_prime "$n"
done