# Sanic Base Image

## Getting Started
- Copy `app-base/Dockerfile` to your app dir
- Copy `app-base/Dockerfile-test` to your app dir
- Copy `blueprint.py` to your app dir
- Copy `orm.py` to your app dir
- Create file `requirements.txt`
- Create file `requirements-test.txt`
- Create folder `tests`

## Packages included

- python 3.7
- sanic
- gunicorn
- gino

For testing:

- pytest
- ipdb

## Files

### `app.py`
Global entrypoint, provided by sanic base image, should not be overridden.

### `blueprint.py`

File contains a blueprint as entrypoint of the app. Use `APP_BLUEPRINT` env to provide an override.

### `orm.py`
File contains an `Gino` instance. Use `APP_ORM` env to provide an override.


### `tests/`
Testing case files.

## Environment Variables

### `APP_BLUEPRINT`
Default to `blueprint.bp`.

### `APP_ORM`
Default to `orm.db`.
You may unset this variable to disable DB access.

## Dockerfile Flow
When writing the Dockerfiles, use this order for the `FROM` command:

- `sanic`
  - In prod img: `FROM` `python`
  - In test img: `FROM` `sanic`
- `sanic` based apps
  - In prod img: `FROM` `sanic`
  - In test img: `FROM` the app's prod img

```
app <-- app-test
 |
 |
 V
sanic <-- sanic-test
```