import asyncio
import traceback
from typing import List
from uuid import uuid4

from temporalio.client import Client, WorkflowFailureError

from config import settings
from schemas.sample_schema import MessageSchema
from workflows.sample_workflow import MessageWorkflow


async def run_workflow(asrparams: MessageSchema):
    """Run the ASR dataset workflow with given parameters."""
    # Connect to Temporal server
    client = await Client.connect(f"{settings.TEMPORAL_SERVER_ENDPOINT}:{settings.TEMPORAL_SERVER_PORT}",
                                  namespace=settings.TEMPORAL_NAMESPACE,
                                  api_key=settings.TEMPORAL_API_KEY,
                                  tls=True
                                  )
    # Start the workflow
    print(f"Starting my workflow...")
    try:
        result = await client.execute_workflow(
            MessageWorkflow.run,
            asrparams,
            id=f"test-workflow-{uuid4()}",
            task_queue="test-queue",
        )
        print(f"Workflow completed: {result}")

    except WorkflowFailureError:
        print("Got expected exception: ", traceback.format_exc())


async def run_multiple_workflows(workflow_params: List[MessageSchema]):
    """Run multiple test workflows concurrently."""
    tasks = [run_workflow(params) for params in workflow_params]
    return await asyncio.gather(*tasks)


if __name__ == "__main__":
    params_list = [
        MessageSchema(
            message="🦄Hello world",
        ),
        MessageSchema(
            message="🐰Bye world",
        ),
    ]
    # Run the workflow
    asyncio.run(run_multiple_workflows(params_list))
