FROM python:3.9-slim

#workdir in the container
WORKDIR /app


COPY src/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY src/ ./

EXPOSE 5000

CMD ["python", "app.py"]