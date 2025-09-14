from dataclasses import dataclass


@dataclass
class MessageSchema:
    """Parameters for Message Activity."""
    message: str
