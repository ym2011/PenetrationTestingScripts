from django.shortcuts import render, redirect
from django.http import HttpResponse
from django.template import loader
from django.utils import timezone
from django.contrib.auth.decorators import login_required

from .models import NmapProfile
from .models import NmapScan
from .models import ScanForm

@login_required(login_url='/login/')
def index(request):
    context = { 'profiles' : NmapProfile.objects.all() }
    template = loader.get_template('index.html')

    if request.method == 'POST':
        f = ScanForm(request.POST)
        if f.is_valid():
            new_scan = f.save(commit=False)
            if not new_scan.valid_target(new_scan.target_text):
                context['popup_message'] = 'Invalid target!'
                new_scan.target_text = "invalid"
            new_scan.status_text = "waiting"
            new_scan.start_date = timezone.now()
            new_scan.end_date = timezone.now()
            if not request.POST['cmd_text']:
                nmap_cmd = NmapProfile.objects.get(id = request.POST['profile'])
                new_scan.cmd_text = "%s %s" % (nmap_cmd.args_text, new_scan.target_text)
            else:
                new_scan.cmd_text = "%s %s" % (request.POST['cmd_text'], new_scan.target_text)
            if new_scan.validate_opts(new_scan.cmd_text) and new_scan.target_text != "invalid":
                context['popup_message'] = 'Your scan has been added to the queue!'
                new_scan.save()
            else:
                context['popup_message'] = 'Not a valid Nmap command!'
        else:
            context['popup_message'] = f.errors

    return HttpResponse(template.render(context, request))

