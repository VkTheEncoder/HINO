# ┌─────────────────────────────────────────────────────────────────────────┐
# │  telegram-hino-bot Dockerfile                                         │
# └─────────────────────────────────────────────────────────────────────────┘

FROM python:3.12-slim

# 1) Install C/C++ build tools + OpenCV & Tesseract headers + Python venv support
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      cmake g++ make \
      libopencv-dev libtesseract-dev pkg-config \
      ffmpeg python3-venv python3-distutils \
    && rm -rf /var/lib/apt/lists/*

# 2) Copy everything (your Python code + HINO C++ code)
WORKDIR /app
COPY . .

# 3) Build HINO from the root CMakeLists.txt
#    This will discover src/, externals/, tests/, etc., and produce
#    the `HardsubIsNotOk` binary at /app/HardsubIsNotOk (or similar).
RUN cmake . \
 && make -j"$(nproc)"

# 4) Create & populate a Python venv, install only the bot’s Python deps
COPY requirements.txt .
RUN python3 -m venv /opt/venv \
 && /opt/venv/bin/pip install --upgrade pip setuptools wheel \
 && /opt/venv/bin/pip install -r requirements.txt

# 5) Ensure venv’s bin/ is on PATH
ENV PATH="/opt/venv/bin:${PATH}"

# 6) Launch the Telegram bot
CMD ["python", "bot.py"]
