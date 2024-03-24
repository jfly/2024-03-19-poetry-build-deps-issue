FROM python:3.11

# Install poetry into a venv (https://python-poetry.org/docs/#installing-with-the-official-installer).
ENV POETRY_HOME=/opt/poetry
ENV PATH=$POETRY_HOME/bin:$PATH
RUN python -m venv $POETRY_HOME && $POETRY_HOME/bin/pip install poetry==1.8.2
RUN $POETRY_HOME/bin/pip install pkginfo==1.10.0

# Start a virtual environment for all further Python invocations
# https://pythonspeed.com/articles/activate-virtualenv-dockerfile/
ENV VIRTUAL_ENV=/opt/venv
ENV PATH=$VIRTUAL_ENV/bin:$PATH
RUN python -m venv $VIRTUAL_ENV

WORKDIR /playground

ENTRYPOINT ["bash"]
