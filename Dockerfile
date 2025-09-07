FROM fedora:latest



# Set environment variables
# ENV DBUS_SESSION_BUS_ADDRESS=/dev/null
# Update package list and install dependencies
RUN dnf update -y && \
    dnf install -y \
        --skip-unavailable \
        # Core system utilities (curl already installed in base image)
        wget \
        gnupg2 \
        # Font packages for proper text rendering
        liberation-fonts \
        dejavu-sans-fonts \
        dejavu-serif-fonts \
        dejavu-sans-mono-fonts \
        # Audio libraries (required by Chrome even in headless mode)
        alsa-lib \
        # X11 libraries (required by Chrome)
        libX11 \
        libXcomposite \
        libXcursor \
        libXdamage \
        libXext \
        libXi \
        libXrandr \
        libXrender \
        libXScrnSaver \
        libXtst \
        # Graphics libraries
        mesa-libgbm \
        # Additional Chrome dependencies
        at-spi2-atk \
        gtk3 \
        gtk3-devel \
        nss \
        cups-libs \
        libdrm \
        libxkbcommon \
        xorg-x11-server-Xvfb \
        nginx && \
    # Clean package cache to reduce image size
    dnf clean all && \
    rm -rf /var/cache/dnf

# Add Google Chrome repository and install Chrome
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /etc/pki/rpm-gpg/google-chrome-key.gpg \
    && echo "[google-chrome]" > /etc/yum.repos.d/google-chrome.repo \
    && echo "name=google-chrome" >> /etc/yum.repos.d/google-chrome.repo \
    && echo "baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64" >> /etc/yum.repos.d/google-chrome.repo \
    && echo "enabled=1" >> /etc/yum.repos.d/google-chrome.repo \
    && echo "gpgcheck=1" >> /etc/yum.repos.d/google-chrome.repo \
    && echo "gpgkey=file:///etc/pki/rpm-gpg/google-chrome-key.gpg" >> /etc/yum.repos.d/google-chrome.repo \
    && dnf install -y google-chrome-stable \
    && dnf clean all

# COPY ./google-chrome-stable-124.0.6367.207-1.x86_64.rpm /tmp/
# RUN dnf install -y /tmp/google-chrome-stable-124.0.6367.207-1.x86_64.rpm \
#     && dnf clean all \
#     && rm -f /tmp/google-chrome-stable-124.0.6367.207-1.x86_64.rpm

# Install Node.js
RUN dnf install -y nodejs npm \
    && dnf clean all

# Create app directory
WORKDIR /app

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf


# Copy and make start script executable
COPY start-chrome.sh /app/start-chrome.sh
RUN chmod +x /app/start-chrome.sh

# Copy package.json and install dependencies
COPY package.json /app/package.json
RUN npm install

# Expose ports
EXPOSE 9234 443

# Set entrypoint
ENTRYPOINT ["/app/start-chrome.sh"]