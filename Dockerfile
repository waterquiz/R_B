FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PORT=5000
ENV DISPLAY=:99
ENV RESOLUTION=1280x720x24

RUN apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    chromium-browser \
    openbox \
    menu \
    python3 \
    python3-pip \
    wget \
    curl \
    tar \
    xdotool \
    x11-utils \
    libegl1 \
    libgl1 \
    libxkbcommon0 \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /usr/bin/chromium-browser /usr/bin/chromium

RUN pip3 install websockify

RUN mkdir -p /app/novnc
RUN wget -qO- https://github.com/novnc/noVNC/archive/refs/tags/v1.4.0.tar.gz | \
    tar xz -C /app/novnc --strip-components=1

COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

WORKDIR /app

EXPOSE 5000
EXPOSE 5900

CMD ["/app/start.sh"]
