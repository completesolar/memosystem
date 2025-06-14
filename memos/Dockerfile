FROM tiangolo/uwsgi-nginx-flask:python3.8
ENV APP=/app

RUN apt-get update && apt-get install -y \
    python3-dev \
    gcc  \
    libc-dev \
    libsasl2-dev \
    python-dev \
    libldap2-dev \
    libssl-dev \
    unixodbc-dev \
    unixodbc \
    libpq-dev \
    default-mysql-client \
    vim
    
# This block loads the drivers required to make pyodbc and microsoft sql server work
# It came from https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver16
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql18
RUN ACCEPT_EULA=Y apt-get install -y mssql-tools18

# Set the working directory to /app
WORKDIR $APP

# Copy the current directory contents into the container at /app 
ADD . $APP

RUN python3 -m venv $APP/env
ENV PATH "${APP}/env/bin:${APP}:${PATH}"

# Install the dependencies
RUN pip install -r requirements.txt

# Mysql client is needed for /actions/script.pl
RUN pip install mysqlclient

ENV STATIC_PATH $APP/memos/static
