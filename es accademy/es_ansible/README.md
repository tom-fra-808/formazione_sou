# Ansible Extra Tracks

Raccolta di tre esercizi Ansible dedicati alla gestione delle variabili sensibili, all'utilizzo di strutture dati complesse e alla generazione dinamica di file tramite template Jinja2. Il laboratorio utilizza una macchina virtuale Vagrant gestita attraverso un inventory Ansible separato.

## Obiettivi

- Proteggere e richiamare variabili con **Ansible Vault**.
- Gestire pacchetti e utenti tramite **liste, dizionari e cicli**.
- Generare e inserire configurazioni dinamiche con **Jinja2**.

## Struttura del progetto

```text
es_extra_tracks/
├── Vagrantfile
├── inventory.ini
├── 1-vault/
│   ├── variabili_vault.yml
│   └── vault.yml
├── 2-liste_dictionaries/
│   ├── pacchetti.yml
│   └── utenti.yml
└── 3-jinja_templates/
    ├── limits.yml
    ├── limits.j2
    ├── access.yml
    └── access.j2
```

## Esercizi

### 1. Ansible Vault

Le variabili vengono cifrate all'interno di `vault.yml` e importate nel playbook tramite la direttiva `vars_files`. Durante l'esecuzione Ansible richiede la password, decifra temporaneamente il contenuto e rende disponibili le variabili alle task.

> [!IMPORTANT]
> Il playbook deve essere avviato con l'opzione `--ask-vault-pass`.

### 2. Liste e dizionari

Un dizionario associa ogni pacchetto allo stato `present` o `absent` e viene elaborato tramite `dict2items`. Una lista di dizionari contiene invece le caratteristiche degli utenti, come nome, gruppo, home directory e shell, permettendo di crearli attraverso un unico ciclo.

### 3. Template Jinja2

I template utilizzano variabili, condizioni e cicli per generare dinamicamente:

- i limiti `nofile`, impostati a `10000` in produzione e a `1000` in collaudo o sviluppo;
- la whitelist da inserire prima della regola generale `- : ALL : ALL` in `/etc/security/access.conf`.

Il contenuto generato viene letto dal controller e inserito sulla macchina target mediante il modulo `blockinfile`.

## Esecuzione

```bash
ansible-playbook -i inventory.ini 1-vault/variabili_vault.yml --ask-vault-pass
ansible-playbook -i inventory.ini 2-liste_dictionaries/pacchetti.yml
ansible-playbook -i inventory.ini 2-liste_dictionaries/utenti.yml
ansible-playbook -i inventory.ini 3-jinja_templates/limits.yml
ansible-playbook -i inventory.ini 3-jinja_templates/access.yml
```
