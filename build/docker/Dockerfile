FROM ubuntu:22.04

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    wget \
    unzip \
    lua5.4 \
    luarocks \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install Lua dependencies
RUN luarocks install busted && \
    luarocks install luacov && \
    luarocks install luacheck && \
    luarocks install ldoc

# Install Node.js dependencies globally
RUN npm install -g webpack webpack-cli rollup

WORKDIR /workspace

CMD ["/bin/bash"]