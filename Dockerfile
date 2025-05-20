# ┌─────────────────────────────────────────────────────────────────────────┐
# │  telegram-hino-bot Dockerfile                                         │
# └─────────────────────────────────────────────────────────────────────────┘

FROM python:3.12-slim

# 1) Install all the C/C++ build deps + FFmpeg/OpenCV/Tesseract dev headers + Python venv
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      cmake g++ make pkg-config \
      libavformat-dev libavdevice-dev libavcodec-dev libavutil-dev libswscale-dev \
      libopencv-dev libtesseract-dev \
      ffmpeg python3-venv python3-distutils \
    && rm -rf /var/lib/apt/lists/*

# 2) Copy the entire repo (both your Python code and HINO's C++ code)
WORKDIR /app
COPY . .

# 3) Configure & build **only** the HardsubIsNotOk executable, skipping tests
RUN cmake . \
 && make HardsubIsNotOk

# 4) Create a Python virtualenv & install the Telegram library
COPY requirements.txt .
RUN python3 -m venv /opt/venv \
 && /opt/venv/bin/pip install --upgrade pip setuptools wheel \
 && /opt/venv/bin/pip install -r requirements.txt

ENV PATH="/opt/venv/bin:${PATH}"

# 5) Default command to run your bot
CMD ["python", "bot.py"]
