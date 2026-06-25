FROM python:3.10-slim

# Set the working directory
WORKDIR /app

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy all the files
COPY . .

# Expose the default port used by Hugging Face Spaces
EXPOSE 7860

# Command to run the API
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "7860"]
