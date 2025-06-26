from abc import ABC, abstractmethod

class BaseEnvClient(ABC):
    @abstractmethod
    def count_running_services(self) -> int:
        pass

    @abstractmethod
    def kill_random_service(self) -> bool:
        pass
