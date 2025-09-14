from datetime import timedelta

from temporalio import workflow
from schemas.test_schema import TestSchema


@workflow.defn
class TestWorkflow:
    @workflow.run
    async def run(self, params: TestSchema) -> dict:
        """
        Main workflow.
        """
        try:
            sample_activity_result = await workflow.execute_activity(
                "sample_activity",
                params,
                start_to_close_timeout=timedelta(minutes=3),
            )

            return {
                "printed_message": sample_activity_result["printed_message"],
                "status": "completed",
            }

        except Exception as e:
            print(f"Workflow failed: {str(e)}")
