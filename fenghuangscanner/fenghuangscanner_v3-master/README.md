# fenghuangscan_v3

wilson@wilson-2:~/tools/fenghuangscanner_$ python main.py -h


usage: main.py [-h] [--ip IP] [--threads THREADS] [--P ISPING]
               [--p USER_PORTS] [--file FILE]

ports&*weak password scanner. teams:xdsec. author: wilson

optional arguments:
  -h, --help         show this help message and exit

  --ip IP            ip like 192.168.1.0/24 or 192.168.0.0/16

  --threads THREADS  Maximum threads, default 50

  --P ISPING         --P not mean no ping frist,default yes

  --p USER_PORTS     --p scan ports;like 21,80,445 or 22-1000

  --file FILE        get ips or domains for this file
