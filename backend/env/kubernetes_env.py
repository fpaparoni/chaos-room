import random
from kubernetes import client, config
from .base import BaseEnvClient

class KubernetesEnv(BaseEnvClient):
    def __init__(self, config_data: dict):
        config_path = config_data.get("config_path")
        self.namespace = config_data.get("namespace", "default")

        config.load_kube_config(config_file=config_path)
        self.v1 = client.CoreV1Api()

    def _get_running_pods(self):
        pods = self.v1.list_namespaced_pod(self.namespace)
        return [pod for pod in pods.items if pod.status.phase == "Running"]

    def count_running_services(self) -> int:
        return len(self._get_running_pods())

    def kill_random_service(self) -> bool:
        pods = self._get_running_pods()
        if not pods:
            return False

        victim = random.choice(pods)
        try:
            self.v1.delete_namespaced_pod(name=victim.metadata.name, namespace=self.namespace)
            return True
        except Exception as e:
            print(f"[ERROR] Failed to delete pod {victim.metadata.name}: {e}")
            return False
