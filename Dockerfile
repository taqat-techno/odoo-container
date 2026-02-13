FROM python:3.12-slim-bookworm

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Generate locale
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3-dev \
    libpq-dev \
    libldap2-dev \
    libsasl2-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    libjpeg-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libwebp-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libxcb1-dev \
    libmagic1 \
    fonts-noto-cjk \
    fonts-noto-core \
    curl \
    gnupg2 \
    xfonts-75dpi \
    xfonts-base \
    && rm -rf /var/lib/apt/lists/*

# Install wkhtmltopdf 0.12.6 for PDF generation
RUN curl -sSL https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_amd64.deb -o /tmp/wkhtmltox.deb \
    && apt-get update && apt-get install -y --no-install-recommends /tmp/wkhtmltox.deb \
    && rm -f /tmp/wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js and rtlcss for RTL support
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g rtlcss \
    && rm -rf /var/lib/apt/lists/*

# Create odoo user and group
RUN groupadd -g 1000 odoo \
    && useradd -u 1000 -g odoo -m -s /bin/bash odoo

# Create directories
RUN mkdir -p /opt/odoo /opt/odoo/source /opt/odoo/custom-addons \
    /var/log/odoo /var/lib/odoo /etc/odoo \
    && chown -R odoo:odoo /opt/odoo /var/log/odoo /var/lib/odoo /etc/odoo

# Install Python dependencies
COPY requirements.txt /opt/odoo/requirements.txt
RUN pip install --no-cache-dir -r /opt/odoo/requirements.txt

# Copy entrypoint script
COPY entrypoint.sh /opt/odoo/entrypoint.sh
RUN chmod +x /opt/odoo/entrypoint.sh

# Expose Odoo ports
EXPOSE 8069 8072

# Set default user
USER odoo

# Set working directory
WORKDIR /opt/odoo/source

ENTRYPOINT ["/opt/odoo/entrypoint.sh"]
CMD ["-c", "/etc/odoo/odoo.conf"]
