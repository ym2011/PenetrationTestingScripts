#!/usr/bin/env python
#
# Generate a list of SAP TCP ports
#
# based on reference document:
# https://help.sap.com/viewer/ports
#
# This code can be used to generate only specific SAP ports
# during a network scan
#
# -- gelim

from pprint import pprint
import argparse
import sys
import re

help_desc='''
Script used to generate list of SAP services ports.
Main idea is to expand SAP notation '32NN' to a lists of ports
3200, 3201, 3202, ...

Example of usage:
- Dump all SAP existing ports
$ sap_ports.py

- Know what kind of services this scripts proposes

$ sap_ports.py --verbose
Admin Services       | Start Service SSL           | 5NN14
Admin Services       | Start Service               | 5NN13
Admin Services       | SAPlpd                      | 515
Admin Services       | SDM                         | 5NN17,5NN18,5NN19
[...]

- Get details about specific port rule

$ sap_ports.py --verbose 33NN
ABAP AS              | Gateway                     | 33NN
Java Central Service | Enqueue Replication         | 33NN
Java Central Service | Gateway                     | 33NN

- Dump all SAP HANA ports for 10 first instances (00 to 09)
$ sap_ports.py --hana --instance 10

- Use this program combined with Nmap

$ nmap -p $(sap_ports.py) 10.3.3.7 -sV --open
Not shown: 4496 closed ports
PORT      STATE SERVICE         VERSION
1128/tcp  open  saphostcontrol  SAPHostControl
3201/tcp  open  sapjavaenq      SAP Enqueue Server
3301/tcp  open  sapgateway      SAP Gateway
3901/tcp  open  sapmsgserver    SAP Message Server
8101/tcp  open  sapms           SAP Message Server httpd release 745 (SID J45)
50000/tcp open  sapnetweawer2   SAP NetWeaver Application Server (Kernel version 7.45, Java version 7.50)
50004/tcp open  sapjavap4       SAP JAVA P4 (Potential internal IP 10.3.3.7)
50007/tcp open  tcpwrapped
50013/tcp open  sapstartservice SAP Maganement Console (SID J45, NR 00)
50014/tcp open  tcpwrapped
50020/tcp open  sapjoin         SAP Java Cluster Join Service
50021/tcp open  jdwp            Java Debug Wire Protocol (Reference Implementation) version 1.8 1.8.0_51
50113/tcp open  sapstartservice SAP Maganement Console (SID J45, NR 01)
50114/tcp open  tcpwrapped
Service Info: Host: java745
'''

ports = { "ABAP AS": {"Dispatcher": "32NN",
                      "Gateway":    "33NN",
                      "Gateway2":   "48NN",
                      "ICM HTTP":   ["80NN", "80"],
                      "ICM HTTPS": ["443NN", "443"],
                      "ICM SMTP":     "25",
                      "ICM Admin": "650NN",
                      "Message Server": ["36NN", "39NN"],
                      "Message Server HTTP": "81NN",
                      "Message Server HTTPS": "444NN",
                      "Central System Log *UDP*": ["12NN", "13NN", "14NN", "15NN"],
},
          "Java AS": {"HTTP":          ["5NN00", "80"],
                      "HTTP over SSL": ["5NN01", "443"],
                      "IIOP initial context": "5NN02",
                      "IIOP over SSL": "5NN03",
                      "P4":            "5NN04",
                      "P4 over HTTP":  "5NN05",
                      "P4 over SSL":   "5NN06",
                      "IIOP":          "5NN07",
                      "Telnet":        "5NN08",
                      "JMS":           "5NN10",
                      "Server Join port": "5NN20",
                      "Server Debug Port": "5NN21"},
          "Java Central Service": {"Enqueue Server": "32NN",
                                   "Enqueue Replication": "33NN",
                                   "Enqueue Replication2": "5NN16",
                                   "Gateway": "33NN",
                                   "Gateway SNC": "48NN",
                                   "Message Server": "36NN",
                                   "Message Server HTTP": "81NN",
                                   "Message Server HTTPS": "444NN"},
          "Admin Services": {"SAPHostControl": "1128",
                             "SAPHostControl SSL": "1129",
                             "Start Service": "5NN13",
                             "Start Service SSL": "5NN14",
                             "SDM": ["5NN17", "5NN18", "5NN19"],
                             "SAP Router": "3299",
                             "NIping": "3298",
                             "SAPlpd": "515",
                             "DTR": "5NN15",
                             "IGS HTTP": "4NN80"
          },
          "TREX": {"RFC Server": "3NN07",
                   "Cruiser": "3NN08",
                   "Python Alert Server": "3NN11",
                   "Indexserver": "3NN16",},
          "HANA": {"SQL indexserver": "3NN15",
                   "SQL multitenant indexserver (41 to 98)": "3NN41",
                   "SQL statisserver": "3NN17",
                   "XS HTTP": "80NN",
                   "XS HTTPS": "43NN",
                   "Internal daemon": "3NN00",
                   "Internal nameserver": "3NN01",
                   "Internal preprocessor": "3NN02",
                   "Internal indexserver": "3NN03",
                   "Internal scriptserver": "3NN04",
                   "Internal statisserver": "3NN05",
                   "Internal webdispatcher": "3NN06",
                   "Internal xsengine": "3NN07",
                   "Internal compileserver": "3NN10",
                   "Internal compileserver": "3NN10",
                   "Internal indexservers": "3NN40",
                   "SAP support hdbrss": "3NN09",
                   "Internal diserver": "3NN25",
                   "xscontroller": "3NN29",
                   "xscontroller data access": "3NN30",
                   "xuaaserver": "3NN31",
                   "xscontroller authentication": "3NN32",
                   "XSA routing by hostnames": "3NN33",
                   "SAP HANA xscontroller app instances": ["510NN", "511NN", "512NN", "513NN", "514NN", "515NN"]},
          "SAP Business Suite": {"CSDM": "20201",
                                 "DCOM": "135",
                                 "Lotus Domino Connector 1": "62026",
                                 "Lotus Domino Connector 2": "62027",
                                 "Lotus Domino Connector 3": "62028",
                                 "Lotus Domino Connector 4": "62029",
          },
          "SAP Enterprise Threat Detection": {
              "ESP Web Sevice Provider": "9786",
              "SAP Enterprise Threat Detection": "10514",
              "Encrypted connection for all others providers (TLS)": "10443"
          },
          "Database":{
              "SAP ASE Databsae": "49NN",
              "MSSQL": "1433",
              "MaxDB": ["7200", "7210", "7269", "7270", "7575"],
              "Oracle Listener": "1527",
          },
          "SAP POS":{
              "Xpress Clinet": "2200",
              "Xpress Server telnet": "2202",
              "Store Data": "10000",
              "Messaging Client": "8300",
              "Mobile POS Think Client": "4NN0",
              "Mobile printer": "61NN",
              "Upgrade Server": ["4404", "4405"],
              "File Transfer Server": "8008",
              "Message Transfer Server": "8400"
          }
}

port_re = r'(\w+)(NN)(\w+)?'

# takes string '33NN' and returns list of str
# ['3300', '3301', ... '3399']
def expand_ports(port_rule, maxi=100):
    port_list = re.split(port_re, port_rule) # split list
    port_list = [e for e in port_list if e not in ['', None]] # clean list

    if len(port_list) > 1:
        temp_list = list()
        for i in xrange(0, maxi):
            port = ''.join(port_list)
            temp_list.append(port.replace('NN', '%.2d' % i))
        return temp_list
    else:
        return port_list
    
def generate_ports(p, maxi):
    merged_list = list()
    for e in p:
        merged_list += expand_ports(e, maxi)
    print ','.join(set(merged_list))

def print_ports(flt=None, ssl=False):
    pl = list()
    for ass in ports.keys():
        for proto in ports[ass].keys():
            if ssl:
                if 'ssl' in proto.lower() or 'https' in proto.lower() or 'tls' in proto.lower():
                    continue
            pl = ports[ass][proto]
            if isinstance(pl, list):
                k = ','.join(pl)
            else:
                k = pl
            if flt:
                if flt.lower() in proto.lower(): print ("%s" % ass).ljust(20) +  (" | %s" % proto).ljust(30) + " | %s" % k
            else:
                print ("%s" % ass).ljust(20) +  (" | %s" % proto).ljust(30) + " | %s" % k

def list_add_or_merge(port_list, elem):
    if isinstance(elem, list):
        port_list += elem
    else:
        port_list.append(elem)
    return port_list

# Get subset of ports via root keys of main port dict
def get_ports_by_cat(asname, ssl=False):
    port_list = list()
    for proto in ports[asname]:
        if ssl:
            if 'ssl' in proto.lower() or 'https' in proto.lower():
                continue
        pl = ports[asname][proto]
        port_list = list_add_or_merge(port_list, pl)
    return port_list

# svc == keyword mayching one of the keys of each application server
# used to match any specific protocol/service indicated as additional argument in command-line
# we walk the main 'port' dict, look for matching subkeys and stack up their port for further
# rendering
def get_ports_by_svc(svc, ssl=False):
    port_list = list()
    for ass in ports.keys():
        for proto in ports[ass].keys():
            if ssl:
                if 'ssl' in proto.lower() or 'https' in proto.lower():
                    continue
            if svc.lower() in proto.lower():
                pl = ports[ass][proto]
                port_list = list_add_or_merge(port_list, pl)
    return port_list

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=help_desc,
                                     formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('-a', '--abap', action='store_true', help='all ports available on ABAP AS')
    parser.add_argument('-j', '--java', action='store_true', help='all ports available on JAVA AS')
    parser.add_argument('-H', '--hana', action='store_true', help='all ports available on HANA AS')
    parser.add_argument('-p', '--pos', action='store_true', help='all ports available on SAP POS')    
    parser.add_argument('-v', '--verbose', action='store_true', help='List ports in verbose way')
    parser.add_argument('-i', '--instance', default=100, type=int,
                        help='Set max instances number (default: 100)')
    parser.add_argument('arguments', metavar='arguments', nargs='*', help='additional parameters like port')
    args = parser.parse_args()

    ports_active = list()
    if args.instance > 100:
        print "Instance number can be maximum 100."
        exit(0)

    if args.verbose:
        if args.arguments:
            print_ports(args.arguments[0])
        else:
            print_ports()
        exit(0)
    # keyword mode
    if len(args.arguments) > 0:
        ports_active += get_ports_by_svc(args.arguments[0])
    if args.java:
        ports_active += get_ports_by_cat('Java AS')
    if args.abap:
        ports_active += get_ports_by_cat('ABAP AS')
    if args.hana:
        ports_active += get_ports_by_cat('HANA')
    if args.pos:
        ports_active += get_ports_by_cat('SAP POS')
    
    # select all ports if no filtering options are set
    if not args.java and not args.abap and not args.hana and not args.pos and not len(args.arguments):
        for k in ports.keys():
            ports_active += get_ports_by_cat(k)
    else:
        # always add the Admin services if we use the filtering options
        ports_active += get_ports_by_cat('Admin Services')
        ports_active += get_ports_by_cat('Database')

    generate_ports(ports_active, args.instance)
