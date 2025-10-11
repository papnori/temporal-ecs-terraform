FROM python:3.12-slim

# Set the working directory inside the container
WORKDIR /app

# Copy Pipfile and Pipfile.lock for dependency management
COPY Pipfile Pipfile.lock /app/

# Update package lists and clean up to reduce image size
RUN apt-get update && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*


# Install pipenv, install dependencies, and remove pipenv after installation
RUN pip install --no-cache-dir pipenv && \
    pipenv install --system --deploy --verbose --clear && \
    pip uninstall pipenv -y

# Copy the application source code into the container
COPY . .

# Set environment variable to ensure Python output is not buffered
ENV PYTHONUNBUFFERED=1

# Run the worker
CMD ["python", "run_worker.py"]

