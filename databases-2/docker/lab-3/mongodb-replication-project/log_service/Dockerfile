FROM python:3.12

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY logger_service.py .

CMD ["python", "logger_service.py"]
