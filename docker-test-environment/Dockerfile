# Dockerfile for the impairment gateway container
FROM oraclelinux:8

RUN yum update -y && \
    yum install -y oracle-epel-release-el8 && \ 
    yum install -y iproute iproute-tc iptables python3.11 python3.11-pip

RUN ln -sf /usr/bin/python3.11 /usr/bin/python3 && \
    ln -sf /usr/bin/pip3.11 /usr/bin/pip3

# Set up your entrypoint script to configure tc and iptables
COPY --chmod=0755 scripts/docker-entrypoint.sh /usr/local/bin/

# Copy the FastAPI app files from the local ./app directory to /app in the container
COPY app /app
# Copy the requirements.txt file from the host into the container at /app
COPY requirements.txt /app/requirements.txt
RUN pip3 install --no-cache-dir -r /app/requirements.txt

# Expose the FastAPI default port
EXPOSE 8000

# Set the entrypoint to the script
ENTRYPOINT ["docker-entrypoint.sh"]
