from pydantic_settings import BaseSettings
from pprint import pprint


class Settings(BaseSettings):
    # AWS credentials
    # AWS_ACCESS_KEY_ID: str
    # AWS_SECRET_ACCESS_KEY: str
    # AWS_SESSION_TOKEN: str

    # Temporal server configuration
    TEMPORAL_SERVER_ENDPOINT: str
    TEMPORAL_SERVER_PORT: int
    TEMPORAL_NAMESPACE: str
    TEMPORAL_API_KEY: str


# Instantiate settings
settings = Settings()
pprint(settings.model_dump())  # Print settings for debugging


