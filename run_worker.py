import asyncio

from temporalio.client import Client
from temporalio.worker import Worker

from config import settings
from activities.sample_activity import message_activity
from workflows.sample_workflow import MessageWorkflow


async def run_worker():
    """Run a Temporal worker to process activities."""
    # Connect to Temporal server
    client = await Client.connect(f"{settings.TEMPORAL_SERVER_ENDPOINT}:{settings.TEMPORAL_SERVER_PORT}",
                                  namespace=settings.TEMPORAL_NAMESPACE,
                                  api_key=settings.TEMPORAL_API_KEY,
                                  tls=True
                                  )

    # Create a worker
    worker = Worker(
        client,
        task_queue="test-queue",  # double check it is the same as in run_workflow.py
        workflows=[MessageWorkflow],
        # Add your other activities here
        activities=[
            message_activity,
        ],
        max_concurrent_workflow_tasks=10,
    )

    # Run the worker
    print("Starting worker...")

    await worker.run()


if __name__ == "__main__":
    asyncio.run(run_worker())
