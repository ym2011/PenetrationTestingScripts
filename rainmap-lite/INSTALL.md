#INSTALLATION
#Prerequisites
- Django (Tested on Django 1.9)
If you do not have Django installed use: `pip install Django`
- lxml
Install it with `pip install lxml`

##Linux/OSX
- Download the code from this repository.
```
git clone https://github.com/cldrn/rainmap-lite
```
- Update BASE_URL, SMTP_USER, SMTP_PASS, SMTP_SERVER and SMTP_PORT in nmaper-cronjob.py with your base URL and SMTP credentials to receive email alerts.  
- Create the database schema 
```
python manage.py migrate 
```
- Load the default scanning profiles data
```
python manage.py loaddata nmapprofiles
```
- Add a cron task to execute nmaper-cronjob.py periodically. For example:
```
*/5 * * * * cd <App path> && /usr/bin/python nmaper-cronjob.py >> /var/log/nmaper.log 2>&1
```
- Run the app (Or install it):
```
python manage.py runserver 0.0.0.0:8080
```
##Adding the first admin user
For security RainmapLite does not have any default administrative user out of box. You need to create one by running the following command:
```
python manage.py createsuperuser
```
