A demonstration of a bug that resulted from a nasty interaction between poetry,
poetry's caching mechanism, pkginfo, and hatchling.

## To repro

Note how locking here *only* mentions hatchling, and none of its dependencies
(such as `packaging`, `patchspec`, and more):

    $ docker compose run poetry-1.8.2-pkginfo-1.9.6 -c 'cd backend-with-mydevpi && poetry lock -vv'
    ...
    Using virtualenv: /opt/venv
    Updating dependencies
    Resolving dependencies...
       1: fact: backend-with-mydevpi is 0.1.0
       1: derived: backend-with-mydevpi
       1: fact: backend-with-mydevpi depends on hatchling (*)
       1: selecting backend-with-mydevpi (0.1.0)
       1: derived: hatchling
       1: selecting hatchling (1.22.3)
       1: Version solving took 0.121 seconds.
       1: Tried 1 solutions.

Whereas if we do the exact same thing but with pypi instead of our devpi
server, we see hatchling's dependencies show up:

    $ docker compose run poetry-1.8.2-pkginfo-1.9.6 -c 'cd backend-with-pypi && poetry lock -vv'
    ...
    Updating dependencies
    Resolving dependencies...
       1: fact: backend-with-pypi is 0.1.0
       1: derived: backend-with-pypi
       1: fact: backend-with-pypi depends on hatchling (*)
       1: selecting backend-with-pypi (0.1.0)
       1: derived: hatchling
       1: fact: hatchling (1.22.3) depends on packaging (>=21.3)
       1: fact: hatchling (1.22.3) depends on pathspec (>=0.10.1)
       1: fact: hatchling (1.22.3) depends on pluggy (>=1.0.0)
       1: fact: hatchling (1.22.3) depends on tomli (>=1.2.2)
       1: fact: hatchling (1.22.3) depends on trove-classifiers (*)
       1: selecting hatchling (1.22.3)
       1: derived: trove-classifiers
       1: derived: tomli (>=1.2.2)
       1: derived: pluggy (>=1.0.0)
       1: derived: pathspec (>=0.10.1)
       1: derived: packaging (>=21.3)
       1: selecting trove-classifiers (2024.3.3)
       1: selecting pathspec (0.12.1)
       1: selecting packaging (24.0)
       1: selecting pluggy (1.4.0)
       1: selecting tomli (2.0.1)
       1: Version solving took 0.321 seconds.
       1: Tried 1 solutions.

Lastly, note how things do work with our devpi server if we use pkginfo 1.10.0:

    $ docker compose run poetry-1.8.2-pkginfo-1.10.0 -c 'cd backend-with-mydevpi && poetry lock -vv'
    ...
    Updating dependencies
    Resolving dependencies...
       1: fact: backend-with-mydevpi is 0.1.0
       1: derived: backend-with-mydevpi
       1: fact: backend-with-mydevpi depends on hatchling (*)
       1: selecting backend-with-mydevpi (0.1.0)
       1: derived: hatchling
       1: fact: hatchling (1.22.3) depends on packaging (>=21.3)
       1: fact: hatchling (1.22.3) depends on pathspec (>=0.10.1)
       1: fact: hatchling (1.22.3) depends on pluggy (>=1.0.0)
       1: fact: hatchling (1.22.3) depends on tomli (>=1.2.2)
       1: fact: hatchling (1.22.3) depends on trove-classifiers (*)
       1: selecting hatchling (1.22.3)
       1: derived: trove-classifiers
       1: derived: tomli (>=1.2.2)
       1: derived: pluggy (>=1.0.0)
       1: derived: pathspec (>=0.10.1)
       1: derived: packaging (>=21.3)
       1: selecting trove-classifiers (2024.3.3)
       1: selecting pathspec (0.12.1)
       1: selecting packaging (24.0)
       1: selecting pluggy (1.4.0)
       1: selecting tomli (2.0.1)
       1: Version solving took 0.323 seconds.
       1: Tried 1 solutions.

## Root cause

You can observe the bug more closely if you look at poetry's caches. For example, note how hatchling has a bunch of null values here:

    root@cab7ab48b821:/playground/demo-with-mydevpi# cat /root/.cache/pypoetry/cache/repositories/mydevpi/41/ff/ca/1f/c6/88/f3/72/41ffca1fc688f372885dfb0f3a5048a441873502be6cfcbaedc36859dfb20eb4; echo
    9999999999{"name": "hatchling", "version": "1.22.3", "summary": null, "requires_dist": null, "requires_python": null, "files": [{"file": "hatchling-1.22.3.tar.gz", "hash": "sha256:adf5d32ab10ac59272cd0bcae9c8193288841860025f2c51df971dae161f8683"}, {"file": "hatchling-1.22.3-py3-none-any.whl", "hash": "sha256:f6602529d17f4c91123b4ffbcd4e0f143d92ba9603716edab4a83785f66e2942"}], "yanked": false, "_cache_version": "2.0.0"}

This ultimately was fixed by
https://bazaar.launchpad.net/~tseaver/pkginfo/trunk/revision/222 (hatchling
1.22.3 uses [core metadata
2.3](https://packaging.python.org/en/latest/specifications/core-metadata/)),
but IMO, this bug is worse than it needs to be because [pkginfo silently
returns an empty array in
`Distribution::_getHeaderAttrs`](https://bazaar.launchpad.net/~tseaver/pkginfo/trunk/view/222/pkginfo/distribution.py#L133),
which causes poetry to think there are no `requires_dist`s. Wouldn't it be better for poetry to just crash?

This only happens when not using pypi because [poetry special cases
pypi](https://github.com/python-poetry/poetry/blob/1.8.2/src/poetry/factory.py#L220-L225),
which under the hood [uses a pypi-specific json
api](https://github.com/python-poetry/poetry/blob/1.8.2/src/poetry/repositories/pypi_repository.py#L133)
to fetch package metadata, whereas [`LegacyRepository::_get_release_info uses
PackageInfo`](https://github.com/python-poetry/poetry/blob/1.8.2/src/poetry/repositories/legacy_repository.py#L125),
which ends up [using `pkginfo` under the
hood](https://github.com/python-poetry/poetry/blob/1.8.2/src/poetry/inspection/info.py#L540).

## Demonstration of pkginfo's behavior

On pkginfo 1.9.6, note how the `requires_dist` array disappears once we get to
hatchling version 1.22.1 (with `metadata_version` 2.3):

    $ pip install pkginfo==1.9.6 >/dev/null && python parse.py
    Parsing hatchling-1.21.1-py3-none-any.whl
        metadata_version: 2.1
        requires_dist: ['editables>=0.3', 'packaging>=21.3', 'pathspec>=0.10.1', 'pluggy>=1.0.0', "tomli>=1.2.2; python_version < '3.11'", 'trove-classifiers']
    Parsing hatchling-1.22.0-py3-none-any.whl
        metadata_version: 2.2
        requires_dist: ['packaging>=21.3', 'pathspec>=0.10.1', 'pluggy>=1.0.0', "tomli>=1.2.2; python_version < '3.11'", 'trove-classifiers']
    Parsing hatchling-1.22.1-py3-none-any.whl
        metadata_version: 2.3
        requires_dist: ()
    Parsing hatchling-1.22.2-py3-none-any.whl
        metadata_version: 2.3
        requires_dist: ()
    Parsing hatchling-1.22.3-py3-none-any.whl
        metadata_version: 2.3
        requires_dist: ()

Whereas on pkginfo 1.10.0, everything looks great:

    $ pip install pkginfo==1.10.0 >/dev/null && python parse.py
    Parsing hatchling-1.21.1-py3-none-any.whl
        metadata_version: 2.1
        requires_dist: ['editables>=0.3', 'packaging>=21.3', 'pathspec>=0.10.1', 'pluggy>=1.0.0', "tomli>=1.2.2; python_version < '3.11'", 'trove-classifiers']
    Parsing hatchling-1.22.0-py3-none-any.whl
        metadata_version: 2.2
        requires_dist: ['packaging>=21.3', 'pathspec>=0.10.1', 'pluggy>=1.0.0', "tomli>=1.2.2; python_version < '3.11'", 'trove-classifiers']
    Parsing hatchling-1.22.1-py3-none-any.whl
        metadata_version: 2.3
        requires_dist: ['packaging>=21.3', 'pathspec>=0.10.1', 'pluggy>=1.0.0', "tomli>=1.2.2; python_version < '3.11'", 'trove-classifiers']
    Parsing hatchling-1.22.2-py3-none-any.whl
        metadata_version: 2.3
        requires_dist: ['packaging>=21.3', 'pathspec>=0.10.1', 'pluggy>=1.0.0', "tomli>=1.2.2; python_version < '3.11'", 'trove-classifiers']
    Parsing hatchling-1.22.3-py3-none-any.whl
        metadata_version: 2.3
        requires_dist: ['packaging>=21.3', 'pathspec>=0.10.1', 'pluggy>=1.0.0', "tomli>=1.2.2; python_version < '3.11'", 'trove-classifiers']
