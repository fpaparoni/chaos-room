import random
from .base import BaseEnvClient

class AzureEnv(BaseEnvClient):
    def __init__(self, config_data: dict):
        self.running_services = ["az-svc-1", "az-svc-2", "az-svc-3"]

    def count_running_services(self) -> int:
        return len(self.running_services)

    def kill_random_service(self) -> bool:
        if not self.running_services:
            return False

        victim = random.choice(self.running_services)
        print(f"[MOCK] Azure would terminate: {victim}")
        self.running_services.remove(victim)
        return True
