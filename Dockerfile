# syntax=docker/dockerfile:1
FROM python:3.12-slim

LABEL maintainer="Nora Pap"
LABEL email="Nori.753@gmail.com"
LABEL description="Dockerfile for Temporal Worker"

# Create working directory
WORKDIR /app

# Copy dependency files first (for better layer caching)
COPY Pipfile Pipfile.lock /app/

# Update apt and clean up cache to reduce image size
RUN apt-get update && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*


# Install dependencies
RUN pip install --no-cache-dir pipenv && \
    pipenv install --system --deploy --verbose --clear && \
    pip uninstall pipenv -y


# Copy only the necessary application files
COPY config.py run_worker.py /app/
COPY activities/ /app/activities/
COPY workflows/ /app/workflows/
COPY schemas/ /app/schemas/

# Set environment variable to ensure Python output is not buffered
ENV PYTHONUNBUFFERED=1

# Run the worker
CMD ["python", "run_worker.py"]
