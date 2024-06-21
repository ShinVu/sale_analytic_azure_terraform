FROM hashicorp/terraform

# Install required dependencies
RUN \
  apk update && \
  apk add bash py-pip && \
  apk add --virtual=build gcc libffi-dev musl-dev openssl-dev python3-dev make

# Install azure-cli
RUN pip install azure-cli --break-system-packages

# Purge build
RUN apk del --purge build 

# Copy project source codes to workspace
WORKDIR /workspace 
COPY src .

# Set the entrypoint to sleep indefinitely instead of the default entrypoint
ENTRYPOINT ["sh", "-c", "while true; do sleep 3600; done"]
