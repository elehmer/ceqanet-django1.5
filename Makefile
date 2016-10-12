pkgname = ceqanet
prefix ?= /var/www
rootdir = $(prefix)/ceqanet.ca.gov
pkgroot = $(rootdir)/$(pkgname)

staticdir = $(pkgname)/static
appdirs = $(addprefix $(pkgname)/, app)
# Support virtualenvwrapper installations and ../env
venvdir ?= $(or $(wildcard ../env), $(HOME)/.virtualenvs/$(pkgname))

# The order of fixtures is important as we need to preserve the sequence of
# loading.
fixtures = $(pkgname)/app/fixtures/app.json

# Source files
#pysrc = $(wildcard $(addsuffix /*.py,$(pkgname) $(appdirs) $(pkgname)/config))
#less_src = $(wildcard $(staticdir)/app/styles/*.less)
#coffeesrc = $(wildcard $(staticdir)/app/scripts/*.coffee)
#imgsrc = $(wildcard $(staticdir)/app/components/bootstrap/img/*.png) \
	$(wildcard $(staticdir)/app/components/leaflet/dist/images/*.png)
# Static sources requiring no transformation
#staticsrc = $(staticdir)/app/components/leaflet/dist/leaflet.css
#mapsrc = $(staticdir)/map.xml $(staticdir)/tilestache.cfg

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

.PHONY : all build build-static collectstatic coffee components clean dist \
	migrate npm requirejs venv venv-* watch

all: build

# Build coffeescript in place, r.js handles moving to build dir.
# %.js: %.coffee
# 	coffee -bc $^

# %.pyc: %.py
# 	$(PYC) $^

# $(staticdir)/build/img/%.png: %.png
# 	$(INSTALL) -D -m644 $^ $@

# %.css: %.less
# 	lessc $^ $@
# 	$(INSTALL) -D -m644 $@ $(staticdir)/build/styles/$(@F)

# lesscss: $(less_src:.less=.css)

# $(staticdir)/build/styles/leaflet.css: $(firstword $(staticsrc))
# 	$(INSTALL) -d $(@D)
# 	$(INSTALL) -m644 -t $(@D) $(staticsrc)
# 	sed -i 's|images/|/static/img/|' $@

# coffee: $(coffeesrc:.coffee=.js)

# requirejs: coffee
# 	$(staticdir)/node_modules/.bin/r.js -o $(staticdir)/app/scripts/build.js
# 	$(INSTALL) -m644 $(staticdir)/app/components/requirejs/require.js $(staticdir)/build/js

# # Build project static files
# build-static: coffee $(addprefix $(staticdir)/build/img/,$(notdir $(imgsrc))) \
# 	lesscss $(mapsrc) requirejs $(staticdir)/build/styles/leaflet.css

# $(firstword $(mapsrc)): $(pkgname)/templates/coredata/mapstyles.xml
# 	python manage.py mapconfig --map > $@

# $(lastword $(mapsrc)):
# 	python manage.py mapconfig --tiles > $@

# Create virtualenv for managing Python dependencies
venv: $(venvdir)/bin/activate
$(venvdir)/bin/activate: requirements.txt
	test -d $(venvdir) || virtualenv $(venvdir)
	. $@; pip install -r $^
	touch $@

# # Mapnik is not virtualenv friendly, symlink to the system version.
# venv-mapnik: $(venvdir)/lib/$(pyver)/site-packages/mapnik \
# 			 $(venvdir)/lib/$(pyver)/site-packages/mapnik2
# $(venvdir)/lib/$(pyver)/site-packages/%:
# 	ln -nfs /usr/lib/$(pyver)/dist-packages/$(@F) $@

# # pysqlite must be compiled with extension loading enabled to allow us to use
# # Spatialite when running unit tests.
# venv-pysqlite:
# 	@. $(venvdir)/bin/activate; pip install --no-install pysqlite && \
# 		sed -i '/SQLITE_OMIT_LOAD_EXTENSION/d' $(venvdir)/build/pysqlite/setup.cfg && \
# 		pip install --no-download pysqlite

# npm: $(staticdir)/node_modules
# $(staticdir)/node_modules: $(staticdir)/package.json
# 	cd $(staticdir) && npm install
# 	touch $@

# components: npm $(staticdir)/app/components
# $(staticdir)/app/components: $(staticdir)/bower.json
# 	cd $(staticdir) && bower install
# 	touch $@

#build: venv components migrate build-static collectstatic $(addsuffix c, $(pysrc))
build: venv $(addsuffix c, $(pysrc))

# install:
# 	@$(INSTALL) -d -m755 $(addprefix $(DESTDIR)$(pkgroot)/, \
# 							$(sort $(dir $(pysrc))) $(staticdir))
# 	@git rev-parse HEAD > $(DESTDIR)$(pkgroot)/revision.txt
# 	@$(INSTALL) -m644 $(wildcard $(addprefix $(pkgname)/, *.py*)) \
# 		$(DESTDIR)$(pkgroot)/$(pkgname)
# 	@cp -r $(appdirs) $(addprefix $(pkgname)/, config media templates) \
# 		$(DESTDIR)$(pkgroot)/$(pkgname)
# 	@cp -a $(staticdir)/build $(staticdir)/public $(DESTDIR)$(pkgroot)/$(staticdir)
# 	@$(INSTALL) -m644 manage.py Makefile requirements.txt $(DESTDIR)$(pkgroot)
# 	@rm $(DESTDIR)$(pkgroot)/landcarbon/settings_*.py*

# uninstall:
# 	-[ -d $(DESTDIR)$(rootdir) ] && rm -r $(DESTDIR)$(rootdir)

# # Add purging of venv, components, statics?
# clean:
# 	-[ -d $(staticdir)/build ] && rm -r $(staticdir)/build
# 	-rm $(mapsrc)

# # Create a basic installable package for deployment
# package:
# 	$(MAKE) DESTDIR=pkg uninstall install
# 	tar -czf $(pkgname)-$$(date +%Y%m%d).tar.gz -C pkg$(rootdir) ./

# # Create a source only tarball for release
# dist:
# 	@$(INSTALL) -d $@
# 	git archive --prefix=$(pkgname)/ -o $@/$(pkgname)-$$(date +%Y%m%d).tar.gz HEAD

# # Run unit tests
# check:
# 	python manage.py test --settings=landcarbon.settings_test \
# 		$(subst /,.,$(appdirs))

# $(dir $(fixtures)): $(fixtures)
# 	python manage.py loaddata $(filter $@%, $^)
# 	@touch $@

# migrate-%:
# 	@install -d logs
# 	python manage.py syncdb
# 	python manage.py migrate $*

# # Run migrations for all defined apps
# migrate: $(addprefix migrate-, $(notdir $(appdirs))) $(dir $(fixtures))

# collectstatic:
# 	-@[ -d $(staticdir)/public ] && rm -r $(staticdir)/public
# #-@find $(staticdir)/public -type l -xtype l -delete
# 	@python manage.py collectstatic --noinput -i '*component*'
# 	-@ln -nfs ../data $(staticdir)/public/data

# # Look for new rasters in data dir, update RasterStore model, regenerate
# # mapnik stylesheet and tilestache config.
# loadrasters:
# 	./manage.py loadrstore
# 	$(MAKE) -B $(mapsrc)
# 	./manage.py dumpdata coredata > $(filter %coredata.json, $(fixtures))

# # Watch static assets for changes during interactive development, use
# # inotifywait if inotify-tools are installed.
# watch:
# 	[ -x /usr/bin/inotifywait ] \
# 		&& while inotifywait $(coffeesrc) $(less_src); do sleep 1 && $(MAKE) coffee lesscss; done \
# 		|| watch --interval 1 $(MAKE) coffee lesscss

# # Update raster data on dev server
# push-staticdata:
# 	rsync -rtvzKP --dry-run --delete $(staticdir)/data \
# 		gitdev@caladapt-dev.berkeley.edu:$(pkgroot)/$(staticdir)
