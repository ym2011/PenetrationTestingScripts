How to use nmap-service-probes custom file
------------------------------------------

```
$ git clone https://github.com/gelim/nmap-erpscan
$ cd nmap-erpscan
$ nmap -n --open --datadir . -sV -p $(./sap_ports.py) $TARGET
```
