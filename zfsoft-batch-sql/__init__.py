#!/usr/bin/env python
# -*- coding: utf-8 -*-
from common import *
import util
import miniCurl
curl = miniCurl.Curl()

_G = {
    'scanport':False,
    'subdomain': False,
    'target': 'www.abc.com',
    'disallow_ip':['127.0.0.1'],
    'kv' : {},
    #'user_dict':'user_path '
    #'pass_dict':'pass_path '
    }

util._G = _G

def debug(fmt, *args):
    print(fmt % args)

LEVEL_NOTE = 0
LEVEL_INFO =1
LEVEL_WARNING = 2
LEVEL_HOLE = 3

def _problem(level, body ,uuid):
    debug('[LOG] <%s> %s (uuid=%s)', ['note', 'info', 'warning', 'hole'][level], body,str(uuid))

security_note = lambda body : _problem(LEVEL_NOTE, body,uuid=None)
security_info = lambda body : _problem(LEVEL_INFO, body,uuid=None)
security_warning = lambda body : _problem(LEVEL_WARNING, body,uuid=None)
security_hole = lambda body : _problem(LEVEL_HOLE, body,uuid=None)

def task_push(service, arg, uuid = None, target=None):
    if uuid is None:
        uuid = str(arg)
        
    debug('[JOB] <%s> %s (%s/%s)', service, arg, uuid, target)

