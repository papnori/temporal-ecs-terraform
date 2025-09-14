FROM python:3.12-slim

# create working directory
WORKDIR /app

# copy requirements.txt
COPY Pipfile Pipfile.lock /app/

# install dependencies
# clean up the apt cache by removing /var/lib/apt/lists it reduces image size
RUN apt-get update && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*


# install dependencies
RUN pip install --no-cache-dir pipenv && \
    pipenv install --system --deploy --verbose --clear && \
    pip uninstall pipenv -y

# Copy the application code
COPY . .

# Create directories for data storage
RUN mkdir -p /data/input /data/output

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Expose the port Health check will run on
EXPOSE 8080

# Expose the port Temporal will run on
EXPOSE 7233

# Run the worker
CMD ["python", "run_worker.py"]

