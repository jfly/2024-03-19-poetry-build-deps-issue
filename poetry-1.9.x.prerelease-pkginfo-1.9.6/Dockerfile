FROM python:3.11

# Install poetry into a venv (https://python-poetry.org/docs/#installing-manually).
ENV POETRY_HOME=/opt/poetry
ENV PATH=$POETRY_HOME/bin:$PATH
RUN python -m venv $POETRY_HOME && $POETRY_HOME/bin/pip install --upgrade pip setuptools && $POETRY_HOME/bin/pip install git+https://github.com/python-poetry/poetry.git@2a2abce88d091891f8e7ca2159b943d15ae2e7c3
RUN $POETRY_HOME/bin/pip install pkginfo==1.9.6

# Start a virtual environment for all further Python invocations
# https://pythonspeed.com/articles/activate-virtualenv-dockerfile/
ENV VIRTUAL_ENV=/opt/venv
ENV PATH=$VIRTUAL_ENV/bin:$PATH
RUN python -m venv $VIRTUAL_ENV

WORKDIR /playground

ENTRYPOINT ["bash"]
