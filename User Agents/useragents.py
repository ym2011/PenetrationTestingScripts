__author__ = 'John Berlin (n0tan3rd@gmail.com)'
__version__ = '1.0.0'
__copyright__ = 'Copyright (c) 2018-Present John Berlin'
__license__ = 'MIT'

import time
import csv
import re
from os import path, makedirs
from glob import glob
import argparse
import requests
from bs4 import BeautifulSoup
import ujson as json

RAW_LISTS = 'rawUALists'
"""str: Default raw user agent dump path"""

CSV_DUMP = 'csv'
"""str: Default csv user agent list dump path"""

JSON_DUMP = 'json'
"""str: Default json user agent list dump path"""

WIMB_ORDER_RE = re.compile(r'page(\d+)\.html')
"""re: regular expression helper for sorting paginated ua html files"""

UA_LIST = [
    'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:44.0) Gecko/20100101 Firefox/44.01',
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/'
    '54.0.2840.71 Safari/537.36',
    'Mozilla/5.0 (Linux; Ubuntu 14.04) AppleWebKit/537.36 Chromium/35.0.1870.2 Safa'
    'ri/537.36',
    'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.'
    '0.2228.0 Safari/537.36',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko'
    ') Chrome/42.0.2311.135 '
    'Safari/537.36 Edge/12.246',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, '
    'like Gecko) Version/9.0.2 Safari/601.3.9',
    'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) '
    'Chrome/47.0.2526.111 Safari/537.36',
    'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:54.0) Gecko/20100101 Firefox/54.0',
]
"""list[str]: user agent strings used when fetching the lists"""


def get_xml_lists(save_path):
    """
    Fetches the xml user agent lists and saves them at save_path
    :param str save_path: Path to where to dump the raw user agent xml lists
    """
    with open(path.join(save_path, 'ua_org_allagents.xml'), 'w') as out:
        request = requests.get('http://www.user-agents.org/allagents.xml')
        if request.ok:
            out.write(request.text)
        else:
            print('Could not get http://www.user-agents.org/allagents.xml')

    with open(path.join(save_path, 'techpatterns_com_useragentswitcher.xml'), 'w') as out:
        request = requests.get(
            'https://techpatterns.com/downloads/firefox/useragentswitcher.xml')
        if request.ok:
            out.write(request.text)
        else:
            print(
                'Could not get https://techpatterns.com/downloads/firefox/useragentswitcher.xml')


def gen_from_xml(xml_dir, csv_dir=CSV_DUMP, json_dir=JSON_DUMP):
    """
    Generates csv and json versions of techpatterns_com_useragentswitcher.xml
    and ua_org_allagents.xml
    :param str xml_dir: Path to the directory containing the two user agent lists in xml
    :param str csv_dir: Path to directory to dump the csv files in. Defaults to <cwd>/csv
    :param str json_dir: Path to directory to dump the json files in. Defaults to <cwd>/json
    """
    ua_list = []
    print('Generating user agent list for techpatterns_com_useragentswitcher.xml')
    with open(path.join(xml_dir, 'techpatterns_com_useragentswitcher.xml'), 'r') as iin:
        soup = BeautifulSoup(iin, 'lxml')
        for search_folder in ['Browsers - Windows', 'Browsers - Mac',
                              'Browsers - Linux', 'Browsers - Unix',
                              'Mobile Devices', 'Spiders - Search', 'Miscellaneous']:
            print(search_folder)
            for folder in soup.find_all(
                    'folder', attrs={"description": search_folder}):
                for user_agent in folder.find_all('useragent'):
                    ua_list.append(
                        dict(kind=search_folder, description=user_agent['description'],
                             ua=user_agent['useragent']))
    with open(path.join(csv_dir, 'techpatterns_com_useragentswitcher.csv'), 'w') as csv_out:
        csv_writer = csv.DictWriter(
            csv_out, fieldnames=['kind', 'description', 'ua'])
        csv_writer.writeheader()
        csv_writer.writerows(ua_list)
    with open(path.join(json_dir, 'techpatterns_com_useragentswitcher.json'), 'w') as json_out:
        json_out.write(json.dumps(ua_list))

    ua_list = []
    print('Generating user agent list for ua_org_allagents.xml')
    with open(path.join(xml_dir, 'ua_org_allagents.xml'), 'r') as iin:
        soup = BeautifulSoup(iin, 'xml')
        for user_agent in soup.find_all('user-agent'):
            ua_list.append(dict(description=user_agent.find(
                'Description').text, ua=user_agent.find('String').text))
    with open(path.join(csv_dir, 'ua_org_allagents.csv'), 'w') as csv_out:
        csv_writer = csv.DictWriter(csv_out, fieldnames=['description', 'ua'])
        csv_writer.writeheader()
        csv_writer.writerows(ua_list)
    with open(path.join(json_dir, 'ua_org_allagents.json'), 'w') as json_out:
        json_out.write(json.dumps(ua_list))


def xml_lists(raw_lists_path, csv_dir=CSV_DUMP, json_dir=JSON_DUMP):
    """
    Fetches the xml user agent lists and transforms them into csv and json
    :param str raw_lists_path: Path to directory to dump the raw lists. Defaults to <cwd>/rawUALists
    :param str csv_dir: Path to directory to dump the csv files in. Defaults to <cwd>/csv
    :param str json_dir: Path to directory to dump the json files in. Defaults to <cwd>/json
    """
    get_xml_lists(raw_lists_path)
    gen_from_xml(raw_lists_path, csv_dir=csv_dir, json_dir=json_dir)


def mine_dev_whatismybrowser(browser, save_path=RAW_LISTS, to_page=30):
    """
    Retrieves the user agent strings for a browser listed on
    developers.whatismybrowser.com up to to_pages
    :param str browser: The browser to get the paginated list of user agent strings for
    :param str save_path: The path to a directory to dump the. Defaults to <cwd>/rawUALists
    :param int to_page: How many pages do you want to extract. Defaults to 30
    """
    browser = browser.lower()
    base_url = "https://developers.whatismybrowser.com/useragents/explore/software_name/%s" \
               % browser
    pag_url = base_url + "/%d"
    save_dir = path.join(save_path, '%sUAHTML' % browser)
    save_html = path.join(save_dir, 'page%d.html')
    if not path.exists(save_dir):
        makedirs(save_dir, exist_ok=True)
    count = 0
    with requests.session() as session:
        for i in range(1, to_page + 1):
            request = session.get(pag_url % i,
                                  headers={'User-Agent': UA_LIST[count]}, timeout=5.0)
            count += 1
            if count == 8:
                count = 0
            if request.ok:
                print('Got %s user agents on page %d' % (browser, i))
                with open(save_html % i, 'w') as out:
                    out.write(request.text)
            else:
                print('Could not get %s user agents on page %d' % (browser, i))
            time.sleep(2)


def wimb_page_order(ua_page):
    """
    Helper for collect_ua_whatismybrowser that sorts the pages in correct order
    :param str ua_page: Path to user agent html file
    :return int: user agent pagination index
    """
    return int(WIMB_ORDER_RE.match(path.basename(ua_page)).group(1))


def collect_ua_whatismybrowser(
        browser, raw_dir=RAW_LISTS, csv_dir=CSV_DUMP, json_dir=JSON_DUMP):
    """
    Parses all pages associated with a browser, generating browser.csv and browser.json
    :param str browser: The browser to retrieve user agent strings for
    :param str raw_dir: Path to the directory containing browser html file directory.
    Defaults to <cwd>/rawUALists
    :param str csv_dir: Path to directory to dump the csv files in. Defaults to <cwd>/csv
    :param str json_dir: Path to directory to dump the json files in. Defaults to <cwd>/json
    """
    ua_list = []
    for page in sorted(glob(path.join(raw_dir, path.join(
            '%sUAHTML', '*.html')) % browser), key=wimb_page_order):
        with open(page, 'r') as iin:
            soup = BeautifulSoup(iin, 'lxml')
            for tr in soup.find_all('tr'):
                ua_tds = tr.select('td.useragent')
                if ua_tds:
                    tds = tr.find_all('td')
                    ua_list.append(
                        dict(ua=ua_tds[0].text, version=tds[1].text, commonality=tds[-1].text))
    with open(path.join(csv_dir, '%s.csv' % browser), 'w') as csv_out:
        csv_writer = csv.DictWriter(
            csv_out, fieldnames=['ua', 'version', 'commonality'])
        csv_writer.writeheader()
        csv_writer.writerows(ua_list)
    with open(path.join(json_dir, '%s.json' % browser), 'w') as json_out:
        json_out.write(json.dumps(ua_list))


def whatismybrowser(raw_list_dir, to_page=30,
                    csv_dir=CSV_DUMP, json_dir=JSON_DUMP):
    """
    Fetches user agent strings for Chrome, Firefox, Opera, Safari, IE, Android browser and
    generates csv and json lists of the user agents per browser
    :param str raw_list_dir:
    :param int to_page: How many pages do you want to extract. Defaults to 30
    :param str csv_dir: Path to directory to dump the csv files in. Defaults to <cwd>/csv
    :param str json_dir: Path to directory to dump the json files in. Defaults to <cwd>/json
    """
    browser_list = ['chrome', 'firefox', 'opera',
                    'safari', 'internet-explorer', 'android-browser']
    for browser in browser_list:
        print('Fetching user agent strings for %s' % browser)
        mine_dev_whatismybrowser(
            browser, save_path=raw_list_dir, to_page=to_page)
        print('Collecting user agent strings for %s' % browser)
        collect_ua_whatismybrowser(browser, raw_dir=raw_list_dir,
                                   csv_dir=csv_dir, json_dir=json_dir)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(prog='useragents',
                                     description='Get some user agent string lists')
    parser.add_argument('-d', '--dump', help='Directory to dump the raw lists. '
                                             'Defaults to <cwd>/rawUALists',
                        default=RAW_LISTS, type=str)
    parser.add_argument('-c', '--csv', help='Directory to dump the csv lists in. '
                                            'Defaults to <cwd>/csv',
                        default=CSV_DUMP, type=str)
    parser.add_argument('-j', '--json', help='Directory to dump the json lists in. '
                                             'Defaults to <cwd>/json',
                        default=JSON_DUMP, type=str)
    parser.add_argument('-p', '--pages',
                        help='Number of pages that should be retrieved for '
                             'whatismybrowser user agents. Defaults to 30',
                        default=30, type=int)
    fetch_group = parser.add_mutually_exclusive_group()
    fetch_group.add_argument('-a', '--all',
                             help='Get both xml and whatismybrowser lists',
                             action='store_true', default=True)
    fetch_group.add_argument('-w', '--wimb',
                             help='Get whatismybrowser lists',
                             action='store_true')
    fetch_group.add_argument('-x', '--xml',
                             help='Get xml lists',
                             action='store_true')
    args = parser.parse_args()
    if not path.exists(args.dump):
        makedirs(args.dump)
    if not path.exists(args.csv):
        makedirs(args.csv, exist_ok=True)
    if not path.exists(args.json):
        makedirs(args.json, exist_ok=True)
    if args.all:
        xml_lists(args.dump, csv_dir=args.csv, json_dir=args.json)
        whatismybrowser(args.dump, to_page=args.pages, csv_dir=args.csv, json_dir=args.json)
    elif args.xml:
        xml_lists(args.dump, csv_dir=args.csv, json_dir=args.json)
    elif args.wimb:
        whatismybrowser(args.dump, to_page=args.pages, csv_dir=args.csv, json_dir=args.json)
