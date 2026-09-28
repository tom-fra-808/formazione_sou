<h1 align="center">PROGETTO REVERSE PROXY</h1>

### Creazione di un'infrastruttura virtuale con un server frontend reverse proxy e due server backend 

## Processo logico
Per costruire lo scheletro dell' architettura sarà necessario:
* Computer con browser web
* Virtualbox come hypervisor
* Vagrant come tool di provisioning

Creare la directory del progetto e inizializzarvi il Vagrantfile:
```bash
mkdir rev_proxy_bon
cd rev_proxy_bon
vagrant init
```
Il comando 'vagrant init' crea il Vagrantfile in cui verrà scritta l'intera struttura.


## Schema architettura
```mermaid
flowchart LR
    U[Browser del Mac] -->|HTTP / HTTPS| H[HAProxy Frontend]

    H -->|Percorso /roma| B1[Backend 1]
    H -->|Percorso /lazio| B2[Backend 2]

    B1 --> N1[Nginx - Pagina Roma]
    B2 --> N2[Nginx - Pagina Lazio]
```
## Tabella degli indirizzi

| Vm  | Ip | Ruolo | Percorso|
| ------------- |:-------------:|:--------------:|:-------------:|
| Frontend     | 192.168.50.50    |HAProxy reverse proxy |     /    |
| Backend1     | 192.168.50.51     | Nginx - pagina Roma | /roma |
| Backend2      | 192.168.50.52   | Nginx - pagina Lazio | /lazio |

## Configurazione macchine virtuali
### Configurazione generale
Nella prima parte del Vagrantfile si impostano le configurazioni generali per tutte le Vms.
```ruby
#configurazione generale
Vagrant.configure("2") do |config|
  config.vm.box = "generic/debian12"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 768
    vb.cpus = 1
  end 
```
### Configurazione Backend
Dopodiché si passa alle configurazioni dei due backend che dovranno rimanere nascosti ai vari client ma visibili solo al reverse proxy grazie alle regole del firewall.
(inserisco una sola configurazione di backend'x' generale sia per backend1 che backend2)
```ruby
#backendx configurazione
config.vm.define "backendx" do |backendx|
  #setting hostname
  backendx.vm.hostname = "backendx" 
  #setting rete
  backendx.vm.network "private_network", ip: "192.168.50.5x"
  #provisioning tramite shell
  backendx.vm.provision "shell", inline: <<-SHELL
    #aggiorno elenco pacchetti
        apt-get update
    #installo programmi web e firewall
        apt-get install -y nginx firewalld
    #abilito firewall
        systemctl enable --now firewalld
    #creo una variabile 'zone' in cui identifico la zona corrente del firewall
        ZONE="$(firewall-cmd --get-default-zone)"
    #imposto una regola del firewall backendx grazie alla quale con http solo   frontend può accedervi
        firewall-cmd --permanent --zone="$ZONE" --add-rich-rule='rule family="ipv4" source address="192.168.50.50/32" port port="80" protocol="tcp" accept'
    #ricarico il firewall
        firewall-cmd --reload
        cat > /var/www/html/index.html <<'EOF'
    #configurazione pagina web
    ...
EOF
    #avvio nginx
    systemctl enable --now nginx
    nginx -t
  SHELL
end

```
### Configurazione Frontend
```ruby
config.vm.define "frontend" do |frontend|
  #setting hostname
  frontend.vm.hostname = "frontend"
  #setting network
  frontend.vm.network "private_network", ip: "192.168.50.50"
  #provisioning tramite shell
  frontend.vm.provision "shell", inline: <<-SHELL
    #aggiorno elenco pacchetti 
        apt-get update
    #installo servizi per proxy certificati firewall e web
        apt-get install -y haproxy openssl firewalld curl
    ####
    #CREAZIONE CERTIFICATO
    #creo la cartella dove verrà salvato il certificato
    mkdir -p /etc/haproxy/certs
      #creo il certificato tramite openssl
      #req -x509 crea certificato x509
      #-newkey rsa:2048 crea una chiave RSA da 2048 bit per creare il certificato
      #-sha256 usa sha-256 come algoritmo di hash per la firma
      #-noenc permette la non cifratura della chiave con password
      #-days 365 indica il periodo di validità del certificato
      #-keyout indica il percorso dove salvare la chiave appena generata
      #-out indica il percorso dove salvare il certificato pubblico
      #-subj indica i valori da inserire direttamente per evitare che openssl li chieda all'avvio con domande interattive
      #-addext aggiunge il Subject Alternative Name

      openssl req -x509 -newkey rsa:2048 -sha256 -noenc -days 365 -keyout /etc/haproxy/certs/frontend.key -out /etc/haproxy/certs/frontend.crt -subj "/C=IT/ST=Lazio/L=Roma/O=DevOps Lab/OU=HAProxy/CN=192.168.50.50" -addext "subjectAltName=IP:192.168.50.50,IP:127.0.0.1,DNS:localhost,DNS:frontend"
      #unisco chiave e certificato nel file .pem utilizzato da HAProxy
      cat /etc/haproxy/certs/frontend.crt /etc/haproxy/certs/frontend.key > /etc/haproxy/certs/frontend.pem

    #attivo il programma firewall
    systemctl enable --now firewalld
    #apro servizio http porta 80, https porta 443 e ricarico.
    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=https
    firewall-cmd --reload
    
    #configurazione file .cfg di haproxy
    #global --> impostazioni generali (log e connessioni massime contemporanee)
    #defaults --> impostazioni specifiche per le sezioni successive (tipo di protocollo impostazioni)
    #frontend --> impostazioni per haproxys (porte in ascolto, certificato, redirect, acl, e backend predefinito)
    #backend 1/2 --> impostazioni dei due server di backend
    #backend bilanciato --> in caso non venga specificato un percorso il server sceglierà a chi instradare il traffico
    cat > /etc/haproxy/haproxy.cfg <<EOF
    global
      log /dev/log local0
      maxconn 2048

    defaults
      log global
      mode http
      option httplog
      retries 3

      timeout connect 5s
      timeout client 30s
      timeout server 30s

    frontend fronte
      bind *:80
      bind *:443 ssl crt /etc/haproxy/certs/frontend.pem

      http-request redirect scheme https code 302 unless { ssl_fc }
      
      acl richiesta_roma path -i /roma
      acl richiesta_lazio path -i /lazio

      use_backend backend1 if richiesta_roma
      use_backend backend2 if richiesta_lazio

      default_backend web_servers

    backend backend1
      http-request set-path /

      server backend1 192.168.50.51:80 check inter 2s fall 3 rise 2

    backend backend2
      http-request set-path /

      server backend2 192.168.50.52:80 check inter 2s fall 3 rise 2

      
    backend web_servers
      balance roundrobin

      server backend1 192.168.50.51:80 check inter 2s fall 3 rise 2
      server backend2 192.168.50.52:80 check inter 2s fall 3 rise 2
EOF
    haproxy -c -f /etc/haproxy/haproxy.cfg

    systemctl enable --now haproxy
    systemctl restart haproxy

    systemctl --no-pager status haproxy


  SHELL
  end
end
```
##  Avviare progetto
Nella cartella del progetto, da terminale, eseguire il comando 'vagrant up'.
Le tre VM si accenderanno e configureranno in autmatico.

Aprire il proprio browser web e inserire ip : "192.168.50.50".
Verrà mostrato un avviso sulla non sicurezza del sito dato che il certificato è stato "self-signed", firmato da noi.
Se si continua, il browser dovrebbe mostrare la pagina backend1 e, ogni volta che si refresha la pagina, grazie alla modalità di balance roundrobin nella configurazione di HAProxy, il server mostrerà le pagine alternandole.
