# Use a smaller, modern base image
FROM python:3.9-slim

# Set environment variables (avoid interactive prompts)
ENV DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /app

# Install system dependencies + Microsoft ODBC driver
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    unixodbc \
    unixodbc-dev \
    && curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/debian/12/prod bookworm main" > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first (better caching)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the app
COPY . .

# Run the FastAPI app
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]