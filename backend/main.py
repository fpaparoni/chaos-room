import yaml
from fastapi import FastAPI
from env.factory import get_env_client
import uvicorn

# Load config
with open("config.yaml", "r") as f:
    config = yaml.safe_load(f)

# Create FastAPI app
app = FastAPI()

# Instantiate env client (Kubernetes, AWS or Azure)
env_client = get_env_client(config)

@app.get("/victims")
def get_victim_count():
    """Returns number of services currently running and killable."""
    count = env_client.count_running_services()
    return {"count": count}

@app.post("/kill")
def kill_random():
    """Kills a random service among the currently running ones."""
    success = env_client.kill_random_service()
    return {"success": success}

# Optional for running with `python main.py`
if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8181, reload=True)
