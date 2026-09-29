# Observability con OpenTelemetry, Prometheus e Grafana

## Esercizio

L'esercizio si basa sull'applicazione python gia creata nelle track precedenti.

L'applicazione funziona, ma attualmente non dispone di una piattaforma di observability.

Si richiede di monitorare:

* Quanti TPS sta ricevendo l'applicazione (Transaction Per Second)
* Quali endpoint vengono utilizzati maggiormente
* Qual è il rate di errori HTTP
* Qual è la latenza delle richieste
* Quali pod stanno gestendo il traffico

Il compito è di introdurre **OpenTelemetry** nell'applicazione e predisporre una pipeline di raccolta e visualizzazione delle metriche tramite **Prometheus + Grafana**.

---

# Obiettivo

L'architettura finale dovrà somigliare a qualcosa del genere

```text
                    ┌───────────────┐
                    │   Flask App   │
                    │               │
                    │ OpenTelemetry │
                    └──────┬────────┘
                           │
                           │ metrics
                           ▼
                    ┌──────────────┐
                    │  Prometheus  │
                    └──────┬───────┘
                           │
                           │ PromQL
                           ▼
                    ┌──────────────┐
                    │   Grafana    │
                    └──────────────┘
```

L'applicazione dovrà essere strumentata utilizzando **OpenTelemetry con strumentazione automatica**, evitando ove possibile modifiche al codice Flask.

Prometheus dovrà raccogliere le metriche e Grafana dovrà permettere di visualizzarle tramite una dashboard.

---

### Vincolo

Non devi introdurre manualmente uno span in ogni endpoint.

> **Non modificare l'applicazione per "costruire a mano" le metriche che OpenTelemetry è in grado di ottenere tramite auto-instrumentation.**

L'obiettivo dell'esercizio è dimostrare che sai prendere un'applicazione Python esistente e aggiungere una piattaforma di observability **con il minor impatto possibile sul codice applicativo**, gestendo correttamente Docker, Kubernetes, Helm, OpenTelemetry, Prometheus e Grafana.

---

### Requisiti

La soluzione deve essere:

* containerizzata;
* deployabile su Kubernetes;
* configurabile tramite Helm;
* riproducibile da zero.

---

# Helm

Modificare il chart Helm esistente in modo da poter configurare l'observability tramite `values.yaml`.

Dovrebbero essere configurabili almeno:

```yaml
observability:
  enabled: true

otel:
  enabled: true
  serviceName: flask-app
  exporterEndpoint: ...

prometheus:
  enabled: true

grafana:
  enabled: true
```

La struttura esatta è libera.

# Dashboard

La dashboard deve contenere almeno i seguenti pannelli.

### 1. Request rate

Numero di richieste al secondo.

Deve essere possibile distinguere almeno gli endpoint principali.

---

### 2. HTTP errors

Visualizza il numero di risposte:

```text
4xx
5xx
```

nel tempo.

---

### 3. Request latency

Visualizza la latenza delle richieste.

Preferibilmente rappresentando almeno:

```text
p50
p95
p99
```

se le metriche disponibili lo consentono.

---

### 4. Requests by endpoint

Mostra quali endpoint stanno ricevendo più richieste.

---

# Test dell'observability

Una volta completato il deployment, crea uno script che generi svariate richieste sui vari endpoint cosi da poter generare un numero deterministico di richieste e confrontarle con quanto mostrato nei grafici. 

Puoi utilizzare uno script con `curl` in loop.

L'obiettivo è produrre una situazione simile a:

```text
200 → /
200 → /api/
404 → /appi/
...
```

Verificare quindi che:

1. Prometheus riceva le metriche;
2. Grafana le visualizzi;
3. le richieste siano distinguibili per endpoint;
4. gli errori HTTP siano visibili;
5. la latenza venga registrata;

---

# Scaling Kubernetes

Scala l'applicazione:

```bash
kubectl scale deployment flask-app --replicas=3
```

Genera nuovamente traffico.

Verifica in Grafana se riesci a distinguere il traffico prodotto dai diversi pod.



Il README deve spiegare:

1. come avviare l'ambiente;
2. come installare il chart;
3. come accedere a Prometheus;
4. come accedere a Grafana;
5. come verificare che OpenTelemetry sia attivo;
6. come generare traffico;
7. quali metriche sono disponibili;
8. quali query PromQL sono state utilizzate;
9. come è stata realizzata la pipeline delle metriche;
10. eventuali compromessi o limitazioni della soluzione.

---

# Criteri di verifica

La soluzione è considerata completa quando:

* [-] l'app Flask continua a funzionare;
* [-] l'immagine Docker viene costruita correttamente;
* [-] OpenTelemetry è integrato;
* [-] viene utilizzata la strumentazione automatica;
* [-] il codice Flask richiede modifiche minime o nulle;
* [-] le metriche arrivano a Prometheus;
* [-] Prometheus riesce a fare scraping/raccogliere le metriche;
* [-] Grafana utilizza Prometheus come datasource;
* [-] Grafana contiene una dashboard funzionante;
* [-] request rate è visualizzato;
* [-] error rate è visualizzato;
* [-] latenza è visualizzata;
* [-] gli endpoint sono distinguibili;
* [-] i pod sono distinguibili;
* [-] l'intera soluzione è deployabile tramite Helm;
* [-] non sono necessarie modifiche manuali al cluster dopo il deployment.

---

# Bonus

Per rendere l'esercizio più vicino a un ambiente production-like, implementa anche:

### Bonus — OpenTelemetry Collector

Inserisci esplicitamente un Collector:

```text
Flask
 ↓
OTel Collector
 ↓
Prometheus
 ↓
Grafana
```

Configurare il Collector tramite Kubernetes/Helm.

---

