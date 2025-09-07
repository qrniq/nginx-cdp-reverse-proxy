# Use Fedora as base image - provides modern packages and good compatibility with Chrome
FROM fedora:latest



# Set environment variables
# ENV DBUS_SESSION_BUS_ADDRESS=/dev/null
# Update system packages and install all Chrome dependencies in single layer for efficiency
RUN dnf update -y && \
    dnf install -y \
        --skip-unavailable \
        # Core system utilities (curl already installed in base image)
        wget \
        gnupg2 \
        # Font packages for proper text rendering in Chrome
        liberation-fonts \
        dejavu-sans-fonts \
        dejavu-serif-fonts \
        dejavu-sans-mono-fonts \
        # Audio libraries (required by Chrome even in headless mode)
        alsa-lib \
        # X11 libraries (required by Chrome for window management)
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
        # Graphics libraries for hardware acceleration support
        mesa-libgbm \
        # Additional Chrome runtime dependencies
        at-spi2-atk \
        gtk3 \
        gtk3-devel \
        nss \
        cups-libs \
        libdrm \
        libxkbcommon \
        # Virtual framebuffer for headless display
        xorg-x11-server-Xvfb \
        # Web server for serving content
        nginx && \
    # Clean package cache to reduce image size
    dnf clean all && \
    rm -rf /var/cache/dnf

# Download Google's signing key and configure Chrome repository for secure installation
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /etc/pki/rpm-gpg/google-chrome-key.gpg \
    # Create Chrome repository configuration file
    && echo "[google-chrome]" > /etc/yum.repos.d/google-chrome.repo \
    # Set repository name
    && echo "name=google-chrome" >> /etc/yum.repos.d/google-chrome.repo \
    # Point to Google's official Chrome RPM repository
    && echo "baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64" >> /etc/yum.repos.d/google-chrome.repo \
    # Enable the repository
    && echo "enabled=1" >> /etc/yum.repos.d/google-chrome.repo \
    # Enable GPG signature verification for security
    && echo "gpgcheck=1" >> /etc/yum.repos.d/google-chrome.repo \
    # Specify the GPG key location for verification
    && echo "gpgkey=file:///etc/pki/rpm-gpg/google-chrome-key.gpg" >> /etc/yum.repos.d/google-chrome.repo \
    # Install Chrome stable version from the configured repository
    && dnf install -y google-chrome-stable \
    # Clean up package cache to reduce image size
    && dnf clean all

# COPY ./google-chrome-stable-124.0.6367.207-1.x86_64.rpm /tmp/
# RUN dnf install -y /tmp/google-chrome-stable-124.0.6367.207-1.x86_64.rpm \
#     && dnf clean all \
#     && rm -f /tmp/google-chrome-stable-124.0.6367.207-1.x86_64.rpm

# Install Node.js runtime and npm package manager for running JavaScript applications
RUN dnf install -y nodejs npm \
    # Clean up package cache to reduce image size
    && dnf clean all

# Set working directory where the application files will be placed
WORKDIR /app

# Copy custom nginx configuration to replace default settings
COPY nginx.conf /etc/nginx/nginx.conf


# Copy startup script that will launch Chrome and other services
COPY start-chrome.sh /app/start-chrome.sh
# Make the startup script executable
RUN chmod +x /app/start-chrome.sh

# Copy package.json to install Node.js application dependencies
COPY package.json /app/package.json
# Install all npm dependencies defined in package.json
RUN npm install

# Expose ports for external access
# Port 9234: Chrome DevTools debugging protocol
# Port 443: HTTPS traffic through nginx
EXPOSE 9234 443

# Set the startup script as the container's entry point
ENTRYPOINT ["/app/start-chrome.sh"]