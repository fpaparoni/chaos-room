import random
from kubernetes import client, config
from .base import BaseEnvClient

class KubernetesEnv(BaseEnvClient):
    def __init__(self, service:str, config_data: dict):
        config_path = config_data.get("config_path")
        self.namespace = config_data.get("namespace", "default")

        config.load_kube_config(config_file=config_path)
        self.v1 = client.CoreV1Api()
        self.service=service

    def _get_running_pods(self):
        pods = self.v1.list_namespaced_pod(self.namespace)
        running_pods = []

        for pod in pods.items:
            if pod.status.phase != "Running":
                continue

            # Remove terminating pod
            if pod.metadata.deletion_timestamp:
                continue

            # Check if there is at least one ready and running container
            all_ready = True
            if pod.status.container_statuses:
                for status in pod.status.container_statuses:
                    if not (status.ready and status.state.running):
                        all_ready = False
                        break
            else:
                all_ready = False

            if all_ready:
                running_pods.append(pod)

        return running_pods


    def count_running_services(self) -> int:
        if not super().check_service(self.service):
            print("Dice che non va il servizio")
            return 0
        else:
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
