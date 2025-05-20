# ┌─────────────────────────────────────────────────────────────────────────┐
# │  telegram-hino-bot Dockerfile                                         │
# └─────────────────────────────────────────────────────────────────────────┘

FROM python:3.12-slim

# 1) Install C/C++ toolchain + FFmpeg/OpenCV/Tesseract headers + Python venv
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      cmake g++ make pkg-config \
      libavformat-dev libavdevice-dev libavcodec-dev libavutil-dev libswscale-dev \
      libopencv-dev libtesseract-dev \
      ffmpeg python3-venv python3-distutils \
    && rm -rf /var/lib/apt/lists/*

# 2) Build **only** the HardsubIsNotOk CLI from the root CMakeLists.txt
WORKDIR /app
COPY . .

# Generate build files & compile the HardsubIsNotOk target (skips tests)
RUN cmake . \
 && make HardsubIsNotOk

# 3) Create & populate a Python venv, install your bot’s Python deps
COPY requirements.txt .
RUN python3 -m venv /opt/venv \
 && /opt/venv/bin/pip install --upgrade pip setuptools wheel \
 && /opt/venv/bin/pip install -r requirements.txt

ENV PATH="/opt/venv/bin:${PATH}"

# 4) Launch the bot
CMD ["python", "bot.py"]
