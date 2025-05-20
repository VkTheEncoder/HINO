FROM python:3.12-slim

# 1) Install C/C++ toolchain + FFmpeg/OpenCV/Tesseract dev headers + venv support
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      cmake g++ make pkg-config \
      libavformat-dev libavdevice-dev libavcodec-dev libavutil-dev libswscale-dev \
      libopencv-dev libtesseract-dev \
      ffmpeg python3-venv python3-distutils \
    && rm -rf /var/lib/apt/lists/*

# 2) Copy the entire repo (your Python code + HINO C++ sources + CMakeLists.txt)
WORKDIR /app
COPY . .

# 3) Out-of-source build: disable testing, build only the CLI
RUN mkdir -p build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF && \
    make HardsubIsNotOk

# 4) Set up Python venv & install the Telegram library
COPY requirements.txt .
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip setuptools wheel && \
    /opt/venv/bin/pip install -r requirements.txt

ENV PATH="/opt/venv/bin:${PATH}"

# 5) Run the bot
CMD ["python", "bot.py"]
