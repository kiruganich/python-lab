FROM python:3.12-slim AS builder

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

COPY . .

RUN touch src/__init__.py

FROM gcr.io/distroless/python3-debian12

COPY --from=builder /root/.local /root/.local
COPY --from=builder /app /app

WORKDIR /app

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python -c "import src.power; print('Health check OK')" || exit 1

ENTRYPOINT ["python", "-m", "src.main"]