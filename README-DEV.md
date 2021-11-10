
# Development environment
__create a Python virtual environment__

`virtualenv -p python3 venv`

__activate the virtualenv__

`source venv/bin/activate`

__install dependencies__

`pip3 install -r requirements.txt`


### Project is using pre-commit Python framework
Runs black Code Formatter and Flake8 checker to format and check our code’s compliance to PEP8.

To install git hooks in your .git/ directory run:

`pre-commit install`

To update to the latest versions of hooks run:

`pre-commit autoupdate`

### Project configuration files
 - .flake8 file configures flake8
 - pyproject.toml file configures black python formatter