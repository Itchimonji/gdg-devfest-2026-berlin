# Open-source container image to run the Cloud Function on Cloud Run or locally
FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PORT=8080

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy function source code
COPY main.py .

# Run the function using Functions Framework
EXPOSE 8080
CMD exec functions-framework --target=store_data --port=${PORT}
