pkgname = ceqanet
prefix ?= /var/www
rootdir = $(prefix)/ceqanet.ca.gov
pkgroot = $(rootdir)/$(pkgname)

staticdir = $(pkgname)/static
appdirs = $(addprefix $(pkgname)/, app)
# Support virtualenvwrapper installations and ../env
venvdir ?= $(or $(wildcard ../env), $(HOME)/.virtualenvs/$(pkgname))

# Environment variables for all subshells.
# Always use a virtualenv.
export VIRTUAL_ENV=$(venvdir)
#export PATH := $(shell pwd)/$(staticdir)/node_modules/.bin:$(venvdir)/bin:$(PATH)
export PATH := $(venvdir)/bin:$(PATH)

#VPATH = $(staticdir)/app/styles:$(staticdir)/app/scripts
#vpath %.coffee $(dir $(coffeesrc))
#vpath %.less $(dir $(less_src))
#vpath %.png $(dir $(imgsrc))

INSTALL ?= install
# Find path to compileall.py to create python bytecode
PYC ?= python $(shell python -c 'import compileall; print(compileall.__file__)')
pyver ?= $(shell python -c \
	"import sys; print('python{}.{}'.format(sys.version_info.major, sys.version_info.minor))")

.PHONY : all build venv watch

all: build

# Create virtualenv for managing Python dependencies
venv: $(venvdir)/bin/activate
$(venvdir)/bin/activate: requirements.txt
	test -d $(venvdir) || virtualenv $(venvdir)
	. $@; pip install -r $^
	touch $@

build: venv $(addsuffix c, $(pysrc))
