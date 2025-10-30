import asyncio
import traceback
from typing import List
from uuid import uuid4

from temporalio.client import Client, WorkflowFailureError

from config import settings
from schemas.sample_schema import SaveMessageSchema
from workflows.sample_workflow import MessageWorkflow


async def run_workflow(params: SaveMessageSchema):
    """Run the save message workflow with the given parameters."""

    # Connect to Temporal server
    url = f"{settings.TEMPORAL_SERVER_ENDPOINT}:{settings.TEMPORAL_SERVER_PORT}" if settings.TEMPORAL_SERVER_PORT else settings.TEMPORAL_SERVER_ENDPOINT

    print(f"Connecting to Temporal server at {url} ...")
    client = await Client.connect(url,
                                  namespace=settings.TEMPORAL_NAMESPACE,
                                  api_key=settings.TEMPORAL_API_KEY,
                                  tls=True
                                  )
    # Start the workflow
    print(f"Starting my workflow...")
    try:
        result = await client.execute_workflow(
            MessageWorkflow.run,
            params,
            id=f"test-workflow-{uuid4()}",
            task_queue="test-queue",
        )
        print(f"Workflow completed: {result}")

    except WorkflowFailureError:
        print("Got expected exception: ", traceback.format_exc())


async def run_multiple_workflows(workflow_params: List[SaveMessageSchema]):
    """Run multiple test workflows concurrently."""
    tasks = [run_workflow(params) for params in workflow_params]
    return await asyncio.gather(*tasks)


if __name__ == "__main__":
    params_list = [
        SaveMessageSchema(
            message="🦄 Hello, World!",
        ),
        SaveMessageSchema(
            message="🐰 Bye, World!",
        ),
    ]
    # Run the workflow
    asyncio.run(run_multiple_workflows(params_list))
