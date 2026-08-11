from fastapi import FastAPI
from prometheus_fastapi_instrumentator import Instrumentator
import logging
import json
import sys

# Structured JSON logging
class JsonFormatter(logging.Formatter):
    def format(self, record):
        return json.dumps({
            "level": record.levelname,
            "msg": record.getMessage(),
            "logger": record.name,
        })

handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(JsonFormatter())
logging.basicConfig(level=logging.INFO, handlers=[handler])
log = logging.getLogger("app")

app = FastAPI(title="sample-fastapi", version="0.1.0")
Instrumentator().instrument(app).expose(app)


@app.get("/")
def root():
    log.info("root called")
    return {"service": "sample-fastapi", "status": "ok"}


@app.get("/healthz")
def healthz():
    return {"status": "healthy"}


@app.get("/readyz")
def readyz():
    return {"status": "ready"}
