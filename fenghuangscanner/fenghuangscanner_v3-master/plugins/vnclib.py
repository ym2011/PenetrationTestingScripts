__author__ = 'wilson'
from Crypto.Cipher import DES
from sys import version_info
import time

class VNC_Error(Exception):
    pass
class VNC:
  def connect(self, host, port, timeout):
    self.fp = socket.create_connection((host, port), timeout=timeout)
    resp = self.fp.recv(99) # banner

    self.version = resp[:11].decode('ascii')

    if len(resp) > 12:
      raise VNC_Error('%s %s' % (self.version, resp[12:].decode('ascii', 'ignore')))

    return self.version

  def login(self, password):
    major, minor = self.version[6], self.version[10]

    if (major, minor) in [('3', '8'), ('4', '1')]:
      proto = b'RFB 003.008\n'

    elif (major, minor) == ('3', '7'):
      proto = b'RFB 003.007\n'

    else:
      proto = b'RFB 003.003\n'

    self.fp.sendall(proto)

    time.sleep(0.5)

    resp = self.fp.recv(99)


    if minor in ('7', '8'):
      code = ord(resp[0:1])
      if code == 0:
        raise VNC_Error('Session setup failed: %s' % resp.decode('ascii', 'ignore'))

      self.fp.sendall(b'\x02') # always use classic VNC authentication
      resp = self.fp.recv(99)

    else: # minor == '3':
      code = ord(resp[3:4])
      if code != 2:
        raise VNC_Error('Session setup failed: %s' % resp.decode('ascii', 'ignore'))

      resp = resp[-16:]

    if len(resp) != 16:
      raise VNC_Error('Unexpected challenge size (No authentication required? Unsupported authentication type?)')


    pw = password.ljust(8, '\x00')[:8] # make sure it is 8 chars long, zero padded

    key = self.gen_key(pw)


    des = DES.new(key, DES.MODE_ECB)
    enc = des.encrypt(resp)


    self.fp.sendall(enc)

    resp = self.fp.recv(99)

    self.fp.close()
    code = ord(resp[3:4])
    mesg = resp[8:].decode('ascii', 'ignore')

    if code == 1:
      return code, mesg or 'Authentication failure'

    elif code == 0:
      return code, mesg or 'OK'

    else:
      raise VNC_Error('Unknown response: %s (code: %s)' % (repr(resp), code))

  def gen_key(self, key):
    newkey = []
    for ki in range(len(key)):
      bsrc = ord(key[ki])
      btgt = 0
      for i in range(8):
        if bsrc & (1 << i):
          btgt = btgt | (1 << 7-i)
      newkey.append(btgt)

    if version_info[0] == 2:
      return ''.join(chr(c) for c in newkey)
    else:
      return bytes(newkey)
