from dataclasses import dataclass


@dataclass
class SaveMessageSchema:
    """Parameters for Message Activity."""
    message: str

    bucket_name: str = "my-little-sample-message-storage-dev"  # S3 bucket name
    file_name: str = "my_little_test.txt"  # Name of the file to save the message
