from time import sleep
from typing import Any
from temporalio import activity

from schemas.test_schema import TestSchema


@activity.defn
async def sample_activity(params: TestSchema) -> dict[str, str | Any]:
    """
    A sample activity that prints a message.
    """
    print("Preparing to print message")
    sleep(5)
    print(params.message)
    print("Phew... done printing!")
    return {"printed_message": params.message,
            "status": "completed"}
