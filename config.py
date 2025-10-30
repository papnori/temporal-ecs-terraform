from pydantic_settings import BaseSettings, SettingsConfigDict
from pprint import pprint


class Settings(BaseSettings):
    # AWS credentials
    # AWS_ACCESS_KEY_ID: str
    # AWS_SECRET_ACCESS_KEY: str
    # AWS_SESSION_TOKEN: str

    # Temporal server configuration
    TEMPORAL_SERVER_ENDPOINT: str
    TEMPORAL_SERVER_PORT: int | None = None
    TEMPORAL_NAMESPACE: str
    TEMPORAL_API_KEY: str | None = None


    # Application data storage configuration
    BUCKET_NAME: str  # AWS S3 bucket name for storing data

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")


# Instantiate settings
settings = Settings()
pprint(settings.model_dump())  # Print settings for debugging


