from django.shortcuts import get_object_or_404, render, redirect
from django.http import HttpResponseRedirect, HttpResponse
from django.contrib.admin.models import LogEntry
from django.core.urlresolvers import reverse
from django.contrib import admin, messages

from nmaper import views, models

admin.site.register(models.NmapScan)
admin.site.register(models.NmapProfile)

def clear_logs(request):
    """Clear admin activity logs if user has permissions"""

    if not request.user.is_authenticated(): # should be applied to anything under /console
        return redirect('login')

    if request.user.has_perm('admin.delete_logentry'):
        LogEntry.objects.all().filter(user__pk=request.user.id).delete()
        messages.info(request, 'Successfully cleared admin activity logs.', fail_silently=True)
    else:
        messages.warning(request, 'Unable to clear the admin activity logs.', fail_silently=True)

    return redirect('admin:index')
