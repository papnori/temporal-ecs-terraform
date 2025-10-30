import os
from datetime import datetime

import boto3
from botocore.config import Config
from typing import Any
from temporalio import activity

from schemas.sample_schema import SaveMessageSchema
from config import settings


@activity.defn
async def save_message_activity(params: SaveMessageSchema) -> dict[str, str | Any]:
    """
    A sample activity to save message to S3.
    """
    print("Preparing to save message...")

    try:
        # Create a file with the current timestamp and save the message to it
        timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
        file_name = f"saved_message_log_{timestamp}.txt"
        print(f"Saving message to {file_name}")

        with open(file_name, "w") as file:
            file.write(params.message)

        # Configure boto3 client with retries
        config = Config(
            retries={'max_attempts': 3, 'mode': 'adaptive'},
            region_name='us-east-1'
        )
        s3_client = boto3.client('s3', config=config)
        s3_client.upload_file(file_name, settings.BUCKET_NAME, file_name)

        # Clean up the temporary file
        os.remove(file_name)

    except Exception as e:
        print(f"S3 upload failed: {str(e)}")
        raise Exception(f"S3 upload failed: {str(e)}") from e

    print("Phew... done saving!")
    return {"saved_message": params.message,
            "s3_path": f"s3://{settings.BUCKET_NAME}/{file_name}",
            "status": "completed"}
