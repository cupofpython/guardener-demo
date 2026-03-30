FROM ubuntu:22.04
RUN apt-get update && apt-get install -y curl git python3
WORKDIR /app
COPY . .
CMD ["python3", "app.py"]
