import random
from .base import BaseEnvClient

class AwsEnv(BaseEnvClient):
    def __init__(self, config_data: dict):
        self.running_services = ["aws-task-1", "aws-task-2", "aws-task-3"]

    def count_running_services(self) -> int:
        return len(self.running_services)

    def kill_random_service(self) -> bool:
        if not self.running_services:
            return False

        victim = random.choice(self.running_services)
        print(f"[MOCK] AWS would terminate: {victim}")
        self.running_services.remove(victim)
        return True
