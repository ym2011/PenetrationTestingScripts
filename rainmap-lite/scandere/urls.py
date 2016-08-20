"""scandere URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/1.9/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  url(r'^$', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  url(r'^$', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.conf.urls import url, include
    2. Add a URL to urlpatterns:  url(r'^blog/', include('blog.urls'))
"""
from nmaper import views
from nmaper.admin import views as adm_views
from django.conf.urls import url, include
from django.contrib import admin
from django.contrib.auth import views as views_django
urlpatterns = [
    url(r'^$', views.index, name='index'),
    url(r'^console/clear_logs/?$', adm_views.clear_logs, name='clear-logs'),
    url(r'^console/', admin.site.urls),
    url(r'^login/$', views_django.login, name='login')
]
