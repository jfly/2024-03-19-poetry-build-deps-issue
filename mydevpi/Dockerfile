FROM python:3.11

# From https://devpi.net/docs/devpi/devpi/stable/+d/quickstart-pypimirror.html
RUN pip install devpi-server
RUN devpi-init

EXPOSE 3141
ENTRYPOINT ["devpi-server", "--listen", "0.0.0.0:3141"]
