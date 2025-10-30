import asyncio

from temporalio.client import Client
from temporalio.worker import Worker

from config import settings
from activities.sample_activity import save_message_activity
from workflows.sample_workflow import MessageWorkflow


async def run_worker():
    """Run a Temporal worker to process activities."""
    # If Port is not specified, assuming Ngrok is used to tunnel to a self-hosted Temporal Server on port 7233
    url = f"{settings.TEMPORAL_SERVER_ENDPOINT}:{settings.TEMPORAL_SERVER_PORT}" if settings.TEMPORAL_SERVER_PORT else settings.TEMPORAL_SERVER_ENDPOINT

    print(f"Connecting to Temporal server at {url} ...")

    # Connect to Temporal server
    client = await Client.connect(
        url,
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
            save_message_activity,
        ],
        max_concurrent_workflow_tasks=10,
    )

    # Run the worker
    print("Starting worker...")

    await worker.run()


if __name__ == "__main__":
    asyncio.run(run_worker())
