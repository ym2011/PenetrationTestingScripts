"""
Basic script to download and manage Nmap's official .nse scripts.

**Features:**
1. Download and update existing .nse scripts from Github.
2. Get basic usage info for any downloaded script.
"""

import re
import sys
import os
import requests
from datetime import datetime
import argparse



__scriptFolder = "nseScripts"
def updateDB():
    extractionRe = re.compile(r'href="(\/nmap\/nmap\/blob\/master\/scripts\/.*?)".*?datetime="(.*?)Z', re.DOTALL)
    nameRe = re.compile(r'scripts/(.*)')
    gitPage = requests.get("https://github.com/nmap/nmap/tree/master/scripts")
    reRes = re.findall(extractionRe, gitPage.content.decode("utf-8"))
    fileDir = os.path.dirname(os.path.abspath(__file__))
    if not os.path.isdir(__scriptFolder):
        os.mkdir(os.path.join(fileDir, __scriptFolder))
    fileDir = os.path.join(fileDir, __scriptFolder)
    try:
        for (httpDir, date) in reRes:
            scriptName = re.search(nameRe, httpDir).group(1)
            fileName = os.path.join(fileDir, scriptName)
            url = "https://raw.githubusercontent.com" + httpDir.replace(r"/blob", "")
            date = int(datetime.fromisoformat(date).timestamp())
            if os.path.isfile(fileName):
                if int(os.path.getmtime(fileName)) == date:
                    print(f"Skipping {scriptName}, unchanged")
                    continue
                else:
                    print(f"Updating {scriptName}")
            else:
                print(f"Downloading {scriptName}")
            subPage = requests.get(url)
            with open(fileName, 'w') as f:
                f.write(subPage.content.decode('utf-8'))
            os.utime(fileName, (datetime.now().timestamp(), date))

    except KeyboardInterrupt:
        print("\nExitting..")
    except:
        print("An error occured")
        return False
    return True
def helper(fileName):
    fileName = os.path.basename(fileName)
    fileName = fileName.replace(".nse", "")
    url = "https://nmap.org/nsedoc/scripts/" + fileName + ".html"
    page = requests.get(url)
    if "Error 404" in page.text:
        print("Page does not exist. Make sure file name is correct")
        return False
    summaryRe = re.compile(r"User Summary.*?p>\n?(.*?)<\/p>", re.DOTALL)
    summary = re.search(summaryRe, page.content.decode('utf-8')).group(1)
    summary = re.sub(r"<.*?>", "", summary)
    print(summary)
    print(f"For more info visit {url}\n")
if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        allow_abbrev=False, description="Nmap .nse script manager")
    parser.add_argument('--update', action='store_true', 
                        help="Update nse script database")
    parser.add_argument('--info', action='store',
                        type=str, metavar="file.nse",
                        help="Basic summary of script in database")
    args = parser.parse_args()
    if len(sys.argv) == 1:
        print("At least one arguement is required, pass with -h for some help")
        quit()
    if args.update:
        updateDB()
    if args.info:
        helper(args.info)
