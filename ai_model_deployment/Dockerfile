FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN apt-get update && apt-get install -y libgomp1 && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .
COPY final_model.pkl .
COPY preprocessor.pkl .

EXPOSE 7860

CMD ["python", "app.py"]
