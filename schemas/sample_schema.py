from dataclasses import dataclass


@dataclass
class SaveMessageSchema:
    """Parameters for Message Activity."""
    message: str
