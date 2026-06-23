FROM python:3.11-slim

WORKDIR /app

# Copy requirements and install dependencies
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files and configurations
COPY app/ ./app/
COPY config/ ./config/

# Expose port (default Flask port)
EXPOSE 5000

# Run the app
CMD ["python", "app/app.py"]
