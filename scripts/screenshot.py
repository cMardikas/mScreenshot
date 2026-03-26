# Author: b0yd @rwincey
# Website: securifera.com
# Simplified and updated by Mart Meier
# Updated for Selenium 4.x

import argparse
import sys
import os
import time
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions import TimeoutException

def navigate_to_url(driver, url):
    try:
        driver.get(url)
        time.sleep(5)
    except Exception as e:
        print(e)
        pass

def take_screenshot(ip, port_arg, query_arg="", output_dir=""):

    host = ip
    empty_page = '<html><head></head><body></body></html>'

    options = Options()
    if os.name == 'nt':
        options.binary_location = 'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe'
    else:
        options.binary_location = '/usr/bin/chromium'

    options.add_argument('--headless=new')
    options.add_argument('--ignore-certificate-errors')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--disable-gpu')
    options.add_argument('--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.6723.69 Safari/537.36')

    try:
        service = Service('/usr/bin/chromedriver')
        driver = webdriver.Chrome(service=service, options=options)
    except Exception as e:
        print(f"Failed to start Chrome: {e}")
        sys.exit(1)

    driver.set_window_size(640, 480)
    driver.set_page_load_timeout(30)

    port = ""
    if port_arg:
        port = ":" + port_arg

    path = host + port
    if query_arg:
        path += "/" + query_arg

    url = "http://" + path
    if port_arg == '443':
        url = "https://" + path

    ret_err = False

    # Go to page
    navigate_to_url(driver, url)

    try:
        source = driver.page_source
        if source == empty_page or 'use the HTTPS scheme' in source or 'was sent to HTTPS port' in source:
            url = "https://" + path
            navigate_to_url(driver, url)
            if driver.page_source == empty_page:
                ret_err = True

        if not ret_err:
            filename = url.replace('https://', '').replace('http://', '').replace(':', '_')
            if host != ip:
                filename += "_" + ip
            if output_dir:
                filename = os.path.join(output_dir, filename)
            driver.save_screenshot(filename + ".png")
            print(f"Saved: {filename}.png")

    except Exception as e:
        print(f"Screenshot error: {e}")
    finally:
        driver.quit()

    if ret_err:
        sys.exit(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Screenshot a website.')
    parser.add_argument('-u', dest='host', help='Website URL', required=True)
    parser.add_argument('-q', dest='query', help='URL Query', required=False)
    parser.add_argument('-p', dest='port', help='Port', required=False)
    parser.add_argument('-o', dest='output_dir', help='Output directory', required=False, default='')
    args = parser.parse_args()

    take_screenshot(args.host, args.port, args.query, args.output_dir)
