import random
import boto3
from botocore.exceptions import BotoCoreError, ClientError
from .base import BaseEnvClient

class AwsEnv(BaseEnvClient):
    """
    Env client for AWS EC2.
    Config keys expected under 'aws' section:
      - region (required)
      - tag_key (optional)  e.g. "chaosroom"
      - tag_value (optional) e.g. "true"
      - state (optional) values like "running, pending" (defaults to running)
    """

    def __init__(self, config_data: dict):
        self.region = config_data.get("region")
        self.tag_key = config_data.get("tag_key")
        self.tag_value = config_data.get("tag_value")
        self.states = config_data.get("states", ["running"])
        # create boto3 client (uses default credentials chain / profile)
        self.client = boto3.client("ec2", region_name=self.region)

    def _instance_filter(self):
        """
        Build AWS describe_instances Filters list based on config.
        """
        filters = []
        if self.states:
            filters.append({"Name": "instance-state-name", "Values": self.states})
        if self.tag_key and self.tag_value is not None:
            filters.append({"Name": f"tag:{self.tag_key}", "Values": [self.tag_value]})
        return filters

    def _get_running_instances(self):
        """
        Returns list of instance dicts (as returned by describe_instances) matching filters.
        Uses paginator to be safe.
        """
        filters = self._instance_filter()
        paginator = self.client.get_paginator("describe_instances")
        instances = []
        try:
            for page in paginator.paginate(Filters=filters) if filters else paginator.paginate():
                for reservation in page.get("Reservations", []):
                    for inst in reservation.get("Instances", []):
                        instances.append(inst)
        except (BotoCoreError, ClientError) as e:
            print(f"[AWSEnv] Error listing instances: {e}")
        return instances

    def count_running_services(self) -> int:
        """
        Return number of matched instances (int).
        """
        instances = self._get_running_instances()
        return len(instances)

    def kill_random_service(self) -> bool:
        """
        Choose one matched instance at random and terminate it.
        Returns True on success, False otherwise.
        """
        instances = self._get_running_instances()
        if not instances:
            print("[AWSEnv] No instances matched to kill.")
            return False

        victim = random.choice(instances)
        instance_id = victim.get("InstanceId")
        try:
            resp = self.client.terminate_instances(InstanceIds=[instance_id])
            print(f"[AWSEnv] Termination requested for {instance_id}: {resp}")
            return True
        except (BotoCoreError, ClientError) as e:
            print(f"[AWSEnv] Failed to terminate {instance_id}: {e}")
            return False