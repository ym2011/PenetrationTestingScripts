# rainmap-lite
Rainmap Lite - Responsive web application that allows users to launch Nmap scans from their mobiles/tablets/web browsers!

Unlike it's predecessor [1], Rainmap-lite does not require special services (RabbitMQ, PostgreSQL, Celery, supervisor, etc) to make it easy to install on any server. You simply need to install the Django application and add the cron polling task to set up a new scanning server. Nmap scans on the road for everyone!

[1] Rainmap - https://nmap.org/rainmap/

## Features
* Easily launch Nmap scans with a few clicks.
* Responsive interface runs smoothly from your phone/tablet. 
* Reports delivered by email in all formats.
* View reports from your web browser.
* Schedule scans.
* Dozens of scanning profiles to choose from.
* Easy to install/set up.
* Share results with your team.

This project is still in beta version. Any feedback, bug reports and PRs are greatly appreciated!

## Demo
https://youtu.be/3oNegHPBd3o

## Documentation
You can find all the documentation related to this project on the [Wiki](https://github.com/cldrn/rainmap-lite/wiki/ "Rainmap Lite Documentation")

## Screenshots
* Responsive interface
<img style="float:center;width:80%" src="https://raw.githubusercontent.com/cldrn/rainmap-lite/master/rainmap-lite-1.png" />
* Customizable
<img style="float:center;width:80%" src="https://raw.githubusercontent.com/cldrn/rainmap-lite/master/screenshots/rainmap-lite-2.png" />
* Scanning profiles
<img style="float:center;width:80%" src="https://raw.githubusercontent.com/cldrn/rainmap-lite/master/screenshots/rainmap-lite-3.png" />
* Site Administration allows managements of users, scanning profiles and scans
<img style="float:center;width:80%" src="https://raw.githubusercontent.com/cldrn/rainmap-lite/master/screenshots/rainmap-lite-4.png" />
<img style="float:center;width:80%" src="https://raw.githubusercontent.com/cldrn/rainmap-lite/master/screenshots/rainmap-lite-5.png" />
* Cron based
<img style="float:center;width:80%" src="https://raw.githubusercontent.com/cldrn/rainmap-lite/master/screenshots/rainmap-lite-6.png" />
* Results delivered by email
<img style="float:center;width:80%" src="https://raw.githubusercontent.com/cldrn/rainmap-lite/master/screenshots/rainmap-lite-7.png" />

