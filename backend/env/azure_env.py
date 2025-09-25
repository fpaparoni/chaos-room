import random
from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient

class AzureEnv:
    def __init__(self, service:str, config_data: dict):
        self.subscription_id = config_data.get("subscription_id")
        self.resource_group = config_data.get("resource_group")
        self.tag_key = config_data.get("tag_key")
        self.tag_value = config_data.get("tag_value")
        self.states = config_data.get("states", ["running"])
        self.service = service
        self.client = ComputeManagementClient(
            credential=DefaultAzureCredential(),
            subscription_id=self.subscription_id
        )

    def _get_running_vms(self):
        vms = []
        for vm in self.client.virtual_machines.list(self.resource_group):
            if not vm.tags or vm.tags.get(self.tag_key) != self.tag_value:
                continue

            instance_view = self.client.virtual_machines.instance_view(
                self.resource_group, vm.name
            )
            statuses = instance_view.statuses or []
            power_state = next(
                (s.code for s in statuses if s.code.startswith("PowerState")), None
            )
            if power_state and any(st in power_state for st in self.states):
                vms.append(vm.name)
        return vms

    def count_running_services(self) -> int:
        return len(self._get_running_vms())

    def kill_random_service(self) -> bool:
        vms = self._get_running_vms()
        if not vms:
            return False
        victim = random.choice(vms)
        self.client.virtual_machines.begin_delete(self.resource_group, victim)
        return True
