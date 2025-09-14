from time import sleep
from typing import Any
from temporalio import activity

from schemas.sample_schema import MessageSchema


@activity.defn
async def message_activity(params: MessageSchema) -> dict[str, str | Any]:
    """
    A sample activity that prints a message.
    """
    print("Preparing to print message")
    sleep(5)
    print(params.message)
    print("Phew... done printing!")
    return {"printed_message": params.message,
            "status": "completed"}
