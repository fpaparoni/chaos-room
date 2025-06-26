# backend/env/factory.py

from env.kubernetes_env import KubernetesEnv
from env.aws_env import AwsEnv
from env.azure_env import AzureEnv

def get_env_client(config: dict):
    env_type = config["env"]
    
    if env_type == "kubernetes":
        return KubernetesEnv(config["kubernetes"])
    elif env_type == "aws":
        return AwsEnv(config["aws"])
    elif env_type == "azure":
        return AzureEnv(config["azure"])
    else:
        raise ValueError(f"Unsupported env type: {env_type}")
