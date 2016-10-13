pkgname = ceqanet
prefix ?= /var/www
rootdir = $(prefix)/ceqanet.ca.gov
pkgroot = $(rootdir)/$(pkgname)

staticdir = $(pkgname)/static
templatesdir = $(pkgname)/templates
# Support virtualenvwrapper installations and ../env
venvdir ?= $(or $(wildcard ../env), $(HOME)/.virtualenvs/$(pkgname))

# Environment variables for all subshells.
# Always use a virtualenv.
export VIRTUAL_ENV=$(venvdir)
export PATH := $(venvdir)/bin:$(PATH)

INSTALL ?= install
# Find path to compileall.py to create python bytecode
PYC ?= python $(shell python -c 'import compileall; print(compileall.__file__)')
pyver ?= $(shell python -c \
	"import sys; print('python{}.{}'.format(sys.version_info.major, sys.version_info.minor))")

.PHONY : all build venv olwidget-templates olwidget-static

all: build

# Create virtualenv for managing Python dependencies
venv: $(venvdir)/bin/activate
$(venvdir)/bin/activate: requirements.txt
	test -d $(venvdir) || virtualenv $(venvdir)
	. $@; pip install -r $^
	touch $@

# Link olwidget template directory in venv to project template dir
olwidget-templates:
	ln -nfs $(venvdir)/olwidget/templates/olwidget $(templatesdir)/olwidget

# Link olwidget static directory in venv to project static dir
olwidget-static:
	ln -nfs $(venvdir)/olwidget/static/olwidget $(staticdir)/olwidget

build: venv olwidget-templates olwidget-static $(addsuffix c, $(pysrc))
