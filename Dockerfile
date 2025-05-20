# ┌─────────────────────────────────────────────────────────────────────────┐
# │  telegram-hino-bot Dockerfile                                         │
# └─────────────────────────────────────────────────────────────────────────┘

FROM python:3.12-slim

# 1) Install build tools + FFmpeg/OpenCV/Tesseract dev headers + venv support
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      cmake g++ make pkg-config \
      libavformat-dev libavdevice-dev libavcodec-dev libavutil-dev libswscale-dev \
      libopencv-dev libtesseract-dev \
      ffmpeg python3-venv python3-distutils \
    && rm -rf /var/lib/apt/lists/*

# 2) Copy your entire repo (includes CMakeLists.txt, src/, externals/, HardsubIsNotOk/ folder, plus bot.py, etc.)
WORKDIR /app
COPY . .

# 3) Out-of-source build for just the CLI binary
RUN mkdir -p build && cd build && \
    cmake .. && \
    make HardsubIsNotOk

# 4) Create & populate a Python venv; install only telegram-bot
COPY requirements.txt .
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip setuptools wheel && \
    /opt/venv/bin/pip install -r requirements.txt

ENV PATH="/opt/venv/bin:${PATH}"

# 5) Start the bot
CMD ["python", "bot.py"]
