# 1) Start from slim Python
FROM python:3.12-slim

# 2) Install C++ toolchain + OpenCV/Tesseract headers
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      cmake g++ make \
      libopencv-dev libtesseract-dev pkg-config \
      ffmpeg python3-venv python3-distutils \
    && rm -rf /var/lib/apt/lists/*

# 3) Build HINO
WORKDIR /app
RUN cmake . && make

# 4) Switch back, install Python deps
WORKDIR /app
COPY requirements.txt .
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip setuptools wheel && \
    /opt/venv/bin/pip install -r requirements.txt

ENV PATH="/opt/venv/bin:${PATH}"

# 5) Copy the rest of your code (including hino/)
COPY . .

# 6) Run your bot
CMD ["python", "bot.py"]
