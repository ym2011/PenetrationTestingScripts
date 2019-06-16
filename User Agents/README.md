# User-Agent Lists

Sometimes you need change the _User-Agent_ string used when making **alot** of requests to the same server(s) often.
- **Research Purposes ONLY**

That can be a hard thing to do if you only know a handful of user agents.

Not to mention building your own comprehensive list of user agent strings takes time.

In the spirit of the [rfc.bib](https://github.com/hupili/rfc.bib) project, this project aims to make a comprehensive set of _User-Agent_ string lists available for all to use.

# Usage
Download a list today free of charge

**OR**

Generate the lists yourself (**Requires python 3.5**)
- ```[sudo] pip install -r  requirements.txt```
- ```python useragents.py --all```

For more options execute ```python useragents.py --help```


# List Info
### Origins
The _User-Agent_ lists made available by this repo come from
- [user-agents.org](http://www.user-agents.org/allagents.xml):  ua_org_allagents.(csv|json)
- [techpatterns.com](https://techpatterns.com/downloads/firefox/useragentswitcher.xml): techpatterns_com_useragentswitcher.(csv|json)
- [developers.whatismybrowser.com](https://developers.whatismybrowser.com/useragents/explore): [browser].(csv|json)

### Flavors
All list provided by this repo come in two flavors namely **csv** and **json**.

Both flavors can be found in a directory of same name and  both flavors share the same "keys".

### Keys
ua_org_allagents.(csv|json)
- **description**: The name of the browser/bot/etc using the _User-Agent_ string
- **ua**: The _User-Agent_ string

techpatterns_com_useragentswitcher.(csv|json)
- **kind**: Is the userof the _User-Agent_ string a browser, mobile, spider
- **description**: Name version (os) for the user of the _User-Agent_ string
- **ua**: The _User-Agent_ string

[browser].(csv|json)
- **ua**: The _User-Agent_ string
- **version**: The version of the browser using the _User-Agent_ string
- **commonality**: How common is this _User-Agent_ string

### User-Agents Included By Each List
ua_org_allagents.(csv|json) provides 2460 User-Agent strings comprised of
- Web Crawlers / Robots
- Browsers (Older)
- Tools (Curl, etc)
- Scanners

techpatterns_com_useragentswitcher.(csv|json) provides 830 User-Agent strings comprised of
- Browsers - Windows
- Browsers - Mac
- Browsers - Linux, Browsers - Unix
- Mobile Devices
- Spiders
- Miscellaneous

[browser].(csv|json) provides 1501 _User-Agent_ strings specific to a browser
- chrome
- firefox
- safari
- opera
- internet-explorer
- android

# License
MIT
