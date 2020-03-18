# Github-Hunter v2.1
This tool is for sensitive information searching on Github.
It's new version of this tool.
## Requirements
Python 3.x <br>
## OS Support
Linux,MacOS,Windows<br>
## Installation
1.`git clone https://github.com/Hell0W0rld0/Github-Hunter.git`<br>
Notice:Github Hunter only supports Python3.x, if you are using Python2.x,do some tests before use it<br>
2.`cd Github-Hunter`<br>
3.`pip install virtualenv`<br>
4.`virtualenv --python=/usr/local/bin/python3 env`<br>
5.`source venv/bin/activate`<br>
6.`pip install -r requirements`<br>
## Settings
Befor use it,you must change parameters in `info.ini.example`,then change filename(just delete `.example`)
### Example
`[KEYWORD]`<br>
`keyword1 = your main keyword here`<br>
`keyword2 = your main keyword here`<br>
`keyword3 = your main keyword here`<br>
`...etc`<br>
<br>
`[EMAIL]`<br>
`host = Email server`<br>
`user = Email User`<br>
`password = Email password`<br>
<br>
`[SENDER]`<br>
`sender = The email sender`<br>
<br>
`[RECEIVER]`<br>
`receiver1 = Email receiver No.1`<br>
`receiver2 = Email receiver No.2`<br>
<br>
`[Github]`<br>
`user = Github Username`<br>
`password = Github Password`<br>
<br>
`[PAYLOADS]`<br>
`p1 = Payload 1`<br>
`p2 = Payload 2`<br>
`p3 = Payload 3`<br>
`p4 = Payload 4`<br>
`p5 = Payload 5`<br>
`p6 = Payload 6`<br>
### Keyword and Payloads
You can add many main keywords as you like, but i suggest add 2~5 keywords.<br>
The tool will combine keyword and payload. So keywords for searching will be "keyword + payload".You can customize your payloads,the more you add, the more sensitive information will be found.
## Run
`python GithubHunter.py`<br>
You will receive emails when application complete.<br>
There will be a .db file named hunter.db, this baseline for url and code. Do not remove it<br>
The emails will be send contain urls and code.
