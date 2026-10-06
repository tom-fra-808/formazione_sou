from flask import Flask
import time

app = Flask(__name__)


@app.route("/")
def hello():
    return "hello world"

@app.route("/api/")
def api():
    time.sleep(0.2)
    return {"message": "API funzionante"}

@app.route("/error")
def error():
    return {"message": "Errore di prova"}, 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
    
