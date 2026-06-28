FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PORT=5000
ENV DISPLAY=:99
ENV RESOLUTION=1280x720x24

RUN apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
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
    gnupg \
    ca-certificates \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q -O /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get update \
    && apt-get install -y /tmp/chrome.deb \
    && rm /tmp/chrome.deb \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /usr/bin/google-chrome-stable /usr/bin/chromium-browser \
    && ln -sf /usr/bin/google-chrome-stable /usr/bin/chromium

RUN pip3 install websockify

RUN mkdir -p /app/novnc
RUN wget -qO- https://github.com/novnc/noVNC/archive/refs/tags/v1.4.0.tar.gz | \
    tar xz -C /app/novnc --strip-components=1

RUN mkdir -p /app/extensions && \
    wget -q -O /tmp/vm.zip \
    https://github.com/violentmonkey/violentmonkey/releases/download/v2.41.0/Violentmonkey-webext-v2.41.0.zip && \
    unzip /tmp/vm.zip -d /app/extensions/violentmonkey && \
    rm /tmp/vm.zip

COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

WORKDIR /app

EXPOSE 5000
EXPOSE 5900

CMD ["/app/start.sh"]
