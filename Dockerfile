FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# ---- System deps ----
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    wget \
    git \
    build-essential \
    ca-certificates \
    gnupg \
    postgresql-client \
    libcairo2 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libgdk-pixbuf2.0-0 \
    libgtk-3-0 \
    libnss3 \
    libasound2 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
 && rm -rf /var/lib/apt/lists/*

# ---- Node.js (via NodeSource) ----
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
 && apt-get update && apt-get install -y nodejs \
 && npm install -g npm@latest

# ---- Python deps ----
RUN python3 -m pip install --upgrade pip

# Core data / DB / viz stack
RUN python3 -m pip install \
    streamlit \
    pandas \
    numpy \
    duckdb \
    sqlalchemy \
    psycopg2-binary \
    plotly \
    seaborn \
    matplotlib \
    altair \
    opencv-python \
    Pillow

# Google APIs (Sheets / Drive)
RUN python3 -m pip install \
    google-api-python-client \
    google-auth \
    google-auth-oauthlib \
    google-auth-httplib2

# Scraping stack
RUN python3 -m pip install \
    requests \
    beautifulsoup4 \
    lxml \
    playwright

# Install Playwright browsers (Chromium)
RUN python3 -m playwright install --with-deps chromium

# Workspace for AI-generated code/projects
WORKDIR /workspace
RUN mkdir -p /workspace

EXPOSE 8501

CMD ["/bin/bash"]
