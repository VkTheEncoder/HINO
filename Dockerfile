# ┌─────────────────────────────────────────────────────────────────────────┐
# │  telegram-hino-bot Dockerfile                                         │
# └─────────────────────────────────────────────────────────────────────────┘

FROM python:3.12-slim

# 1) Install C/C++ build tools + FFmpeg dev headers + OpenCV/Tesseract headers + Python venv support
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      cmake g++ make pkg-config \
      libavformat-dev libavdevice-dev libavcodec-dev libavutil-dev libswscale-dev \
      libopencv-dev libtesseract-dev \
      ffmpeg python3-venv python3-distutils \
    && rm -rf /var/lib/apt/lists/*

# 2) Copy everything (your Python code + all of HINO’s C++ code, with CMakeLists.txt at /app)
WORKDIR /app
COPY . .

# 3) Build HINO in-place
RUN cmake . && make -j"$(nproc)"

# 4) Create & populate a Python venv, install only the Telegram library
COPY requirements.txt .
RUN python3 -m venv /opt/venv \
 && /opt/venv/bin/pip install --upgrade pip setuptools wheel \
 && /opt/venv/bin/pip install -r requirements.txt

ENV PATH="/opt/venv/bin:${PATH}"

# 5) Launch your bot
CMD ["python", "bot.py"]
