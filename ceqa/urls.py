from django.conf.urls import patterns, include, url

# Uncomment the next two lines to enable the admin:
from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    url(r'^',include('ceqanet.urls')),
    # Examples:
    # url(r'^$', 'ceqa.views.home', name='home'),
    # url(r'^ceqa/', include('ceqa.foo.urls')),

    # Uncomment the admin/doc line below to enable admin documentation:
    url(r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    url(r'^admin/', include(admin.site.urls)),
    # registration app urls
    url(r'^accounts/',include('registration.backends.default.urls')),
)
