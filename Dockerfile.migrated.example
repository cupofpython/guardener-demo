FROM cgr.dev/chainguard/wolfi-base
RUN apk add --no-cache curl git python3
WORKDIR /app
COPY . .
CMD ["python3", "app.py"]
