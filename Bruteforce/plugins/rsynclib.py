import base64
import re
try:
    import hashlib
    hash_md4 = hashlib.new("md4")
    hash_md5 = hashlib.md5()
except ImportError:
    # for Python << 2.5
    import md4
    import md5
    hash_md4 = md4.new()
    hash_md5 = md5.new()

# Import SOCKS module if it exists, else standard socket module socket
try:
    import SOCKS; socket = SOCKS; del SOCKS # import SOCKS as socket
    from socket import getfqdn; socket.getfqdn = getfqdn; del getfqdn
except ImportError:
    import socket
from socket import _GLOBAL_DEFAULT_TIMEOUT

__all__ = ["rsync"]



# The standard rsync server control port
RSYNC_PORT = 873
# The sizehint parameter passed to readline() calls
MAXLINE = 8192
protocol_version = 0

# Exception raised when an error or invalid response is received
class Error(Exception): pass

# All exceptions (hopefully) that may be raised here and that aren't
# (always) programming errors on our side
all_errors = (Error, IOError, EOFError)


# Line terminators for rsync
CRLF = '\r\n'
LF = '\n'

# The class itself
class rsync:
    '''An rsync client class.

    To create a connection, call the class using these arguments:
        host, module, user, passwd

    All arguments are strings, and have default value ''.
    Then use self.connect() with optional host and port argument.
    '''
    debugging = 0
    host = ''
    port = RSYNC_PORT
    maxline = MAXLINE
    sock = None
    file = None
    server_protocol_version = None

    # Initialization method (called by class instantiation).
    # Initialize host to localhost, port to standard rsync port
    # Optional arguments are host (for connect()),
    # and module, user, passwd (for login())
    def __init__(self, host='', module='', user='', passwd='',port=873,
                 timeout=_GLOBAL_DEFAULT_TIMEOUT):
        self.timeout = timeout
        if host:
            self.connect(host)
            if module and user and passwd:
                self.login(module, user, passwd)

    def connect(self, host='', port=0, timeout=-999):
        '''Connect to host.  Arguments are:
         - host: hostname to connect to (string, default previous host)
         - port: port to connect to (integer, default previous port)
        '''
        if host != '':
            self.host = host
        if port > 0:
            self.port = port
        if timeout != -999:
            self.timeout = timeout
        self.sock = socket.create_connection((self.host, self.port), self.timeout)
        self.af = self.sock.family
        self.file = self.sock.makefile('rb')
        self.server_protocol_version = self.getresp()
        self.protocol_version = self.server_protocol_version[-2:]
        return self.server_protocol_version


    def set_debuglevel(self, level):
        '''Set the debugging level.
        The required argument level means:
        0: no debugging output (default)
        1: print commands and responses but not body text etc.
        '''
        self.debugging = level
    debug = set_debuglevel

    # Internal: send one line to the server, appending LF
    def putline(self, line):
        line = line + LF
        if self.debugging > 1: print '*put*', line
        self.sock.sendall(line)

    # Internal: return one line from the server, stripping LF.
    # Raise EOFError if the connection is closed
    def getline(self):
        line = self.file.readline(self.maxline + 1)
        if len(line) > self.maxline:
            raise Error("got more than %d bytes" % self.maxline)
        if self.debugging > 1:
            print '*get*', line
        if not line: raise EOFError
        if line[-2:] == CRLF: line = line[:-2]
        elif line[-1:] in CRLF: line = line[:-1]
        return line

    # Internal: get a response from the server, which may possibly
    # consist of multiple lines.  Return a single string with no
    # trailing CRLF.  If the response consists of multiple lines,
    # these are separated by '\n' characters in the string
    def getmultiline(self):
        line = self.getline()
        return line

    # Internal: get a response from the server.
    # Raise various errors if the response indicates an error
    def getresp(self):
        resp = self.getmultiline()
        if self.debugging: print '*resp*', resp
        if resp.find('ERROR') != -1:
            raise Error, resp
        else:
            return resp

    def sendcmd(self, cmd):
        '''Send a command and return the response.'''
        self.putline(cmd)
        return self.getresp()

    def login(self, module='', user = '', passwd = ''):
        if not user: user = 'www'
        if not passwd: passwd = 'www'
        if not module: module = 'www'

        self.putline(self.server_protocol_version)
#        self.putline('@RSYNCD: 28.0')
#        self.protocol_version = 28
        resp = self.sendcmd(module)

        challenge = resp[resp.find('AUTHREQD ')+9:]

        if self.protocol_version >= 30:
            md5=hashlib.md5()
            md5.update(passwd)
            md5.update(challenge)
            hash = base64.b64encode(md5.digest())
        else:
            md4=hashlib.new('md4')
            tmp = '\0\0\0\0' + passwd + challenge
            md4.update(tmp)
            hash = base64.b64encode(md4.digest())

        response, number = re.subn(r'=+$','',hash)
        print response
        resp = self.sendcmd(user + ' ' + response)

        if resp.find('OK') == -1:
            raise Error, resp
        return resp

    def getModules(self):
        '''Get modules on the server'''
        print self.server_protocol_version
        self.putline(self.server_protocol_version)

        resp = self.sendcmd('')
        print resp
        return resp



    def close(self):
        '''Close the connection without assuming anything about it.'''
        self.putline('')
        if self.file is not None:
            self.file.close()
        if self.sock is not None:
            self.sock.close()
        self.file = self.sock = None

