from abc import ABC, abstractmethod
import http.client
import urllib.parse
import logging

class BaseEnvClient(ABC):
    @abstractmethod
    def count_running_services(self) -> int:
        """
        Returns the number of currently running services.
        Must be implemented by subclasses.
        """
        pass

    @abstractmethod
    def kill_random_service(self) -> bool:
        """
        Terminates a randomly selected running service.
        Returns True if the service was successfully killed, False otherwise.
        Must be implemented by subclasses.
        """
        pass


    def check_service(self, service_url: str) -> bool:
        """
        Check if a service is reachable using a raw HTTP GET request.
        If the URL is None or empty, return True by default.

        Args:
            service_url (str): Full URL of the service.

        Returns:
            bool: True if service responds with HTTP 200, False otherwise.
        """
        if not service_url:
            logging.info("No service URL provided, returning True by default")
            return True

        parsed = urllib.parse.urlparse(service_url)

        try:
            conn = http.client.HTTPConnection(parsed.hostname, parsed.port, timeout=10)
            conn.request("GET", parsed.path or "/")
            response = conn.getresponse()
            status = response.status
            conn.close()
            if status == 200:
                logging.info(f"Service reachable at {service_url} (status 200)")
                return True
            else:
                logging.warning(f"Service at {service_url} responded with status {status}")
                return False

        except Exception as e:
            logging.error(f"Error contacting {service_url}: {e}")
            return False