from __future__ import unicode_literals
import re
from django.db import models
from django.forms import ModelForm
from django.core.exceptions import ValidationError

SCAN_STATUS = ( ('waiting','Waiting'),('running','Running'),('finished','Finished') )

def validate_cmd(str):
    valid = re.match('^[\sa-zA-Z0-9_/.,\"\'\=\(\)\*-]*$', str)
    if not valid:
        raise ValidationError(u'%s is not a valid Nmap command' % str)

class NmapProfile(models.Model):
    alias_text = models.CharField(max_length=32)
    args_text = models.CharField(max_length=1024, validators=[validate_cmd])
    pub_date = models.DateTimeField('date created')
    def __str__(self):
        return self.alias_text

class NmapScan(models.Model):
    target_text = models.CharField(max_length=1024)
    cmd_text = models.CharField(max_length=256, validators=[validate_cmd])
    email_text = models.EmailField(max_length=254)
    status_text = models.CharField(max_length=16, choices = SCAN_STATUS)
    start_date = models.DateTimeField('date started')
    end_date = models.DateTimeField('date end')
    uuid = models.CharField(max_length=32)
    def __str__(self):
        return "%s - %s" % (self.cmd_text, self.email_text)
    def valid_chars(self, str):
        valid = re.match('^[\sa-zA-Z0-9_/.,\"\'\=\(\)\*-]*$', str)
        if not valid:
            return False
        return True
    def validate_opts(self, cmd):
        if not self.valid_chars(cmd):
            return False
        for arg in cmd.split(" "):
            if not self.valid_nmap_arg(arg):
                return False
        return True
    def valid_nmap_arg(self, arg):
        #TODO: Add regex to validate Nmap argument
        return True
    def valid_target(self, target):
        if not self.valid_chars(target):
            return False
        return True

class ScanForm(ModelForm):
    class Meta:
        model = NmapScan
        fields = ['target_text', 'email_text']

