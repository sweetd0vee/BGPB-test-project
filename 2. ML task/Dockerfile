FROM python:3.9

WORKDIR /

COPY requirements.txt requirements.txt

COPY . .

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 8000

ENTRYPOINT ["uvicorn", "--host",  "0.0.0.0", "--port",  "8000", "app:app"]
