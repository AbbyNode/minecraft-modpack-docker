FROM mcr.microsoft.com/dotnet/runtime:9.0-bookworm-slim

# Install nginx and cron
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nginx \
        cron \
        curl \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /output /world /unmined /var/log/nginx

# Set up default nginx configuration to serve from /output
RUN rm -f /etc/nginx/sites-enabled/default && \
    echo 'server { \n\
    listen 80 default_server; \n\
    server_name _; \n\
    \n\
    root /output; \n\
    index index.html; \n\
    autoindex off; \n\
    \n\
    add_header X-Frame-Options SAMEORIGIN; \n\
    add_header X-Content-Type-Options nosniff; \n\
    add_header Referrer-Policy no-referrer; \n\
    \n\
    location / { \n\
        try_files $uri $uri/ /index.html; \n\
    } \n\
    \n\
    location ~* \.(?:css|js|png|jpg|jpeg|gif|ico|svg)$ { \n\
        expires 7d; \n\
        access_log off; \n\
    } \n\
}' > /etc/nginx/sites-available/unmined && \
    ln -s /etc/nginx/sites-available/unmined /etc/nginx/sites-enabled/unmined

WORKDIR /

# Expose nginx port
EXPOSE 80

# Default entrypoint will be provided via entrypoint script
