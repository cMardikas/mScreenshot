# Author: b0yd @rwincey
# Website: securifera.com
# Simplified and updated by Mart Meier

import argparse
import http.client, sys
import socket
import json
import os
import time
from selenium import webdriver
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
from selenium.common.exceptions import TimeoutException

def navigate_to_url( driver, url, host ):

    ret_host = None
    print (url)
    try:
        driver.get(url)
        time.sleep(5)
    except Exception as e:
        print (e)
        pass

    return ret_host

def take_screenshot( ip, port_arg, query_arg="" ):

    try:
        host = ip
    except:
        host = ip
        pass

    empty_page = '<html><head></head><body></body></html>'
    caps = DesiredCapabilities.CHROME
    caps['loggingPrefs'] = {'performance': 'ALL'}      # Works prior to chrome 75
    caps['goog:loggingPrefs'] = {'performance': 'ALL'} # Updated in chrome 75
    options = webdriver.ChromeOptions()
    if os.name == 'nt':
        options.binary_location = 'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe'
    else:
        options.binary_location = '/usr/bin/chromium'
        
    options.add_argument('headless')
    options.add_argument('--ignore-certificate-errors')
    options.add_argument('--no-sandbox')
    options.add_argument('--user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.6723.69 Safari/537.36"')

    driver = webdriver.Chrome('chromedriver', options=options, desired_capabilities=caps)
    driver.set_window_size(1024, 768) # set the window size that you need
    driver.set_page_load_timeout(30)
    source = None

    port = ""
    if port_arg:
        port = ":" + port_arg

    #Add query if it exists
    path = host + port
    if query_arg:
        path += "/" + query_arg

    #Get the right URL
    url = "http://" + path
 
    if port_arg == '443':
        url = "https://" + path

    #Retrieve the page
    ret_err = False

    #Enable network tracking
    driver.execute_cdp_cmd('Network.enable', {'maxTotalBufferSize': 2000000, 'maxResourceBufferSize': 2000000, 'maxPostDataSize': 2000000})

    #Goto page
    ret_host = navigate_to_url(driver, url, host)
    
    try: 
        if driver.page_source == empty_page or 'use the HTTPS scheme' in driver.page_source or 'was sent to HTTPS port' in driver.page_source:
            url = "https://" + path
            #print url
            ret_host = navigate_to_url(driver, url, host)
            if driver.page_source == empty_page:
                ret_err = True

        if ret_err == False:
            #Cleanup filename and save
            filename = url.replace('https://', '').replace('http://','').replace(':',"_")
            if host != ip:
                filename += "_" + ip
            driver.save_screenshot(filename + ".png")

        #If the SSL certificate references a different hostname
        if ret_host:

            #Replace any wildcards in the certificate
            ret_host = ret_host.replace("*.", "")
            url = "https://" + ret_host + port

            navigate_to_url(driver, url, ret_host)
            if driver.page_source != empty_page:
                filename = url.replace('https://', '').replace('http://','').replace(':',"_")
                if host != ip:
                    filename += "_" + ip
                driver.save_screenshot(filename + ".png")
        
    except:
        pass
    finally:
        source = driver.page_source
        driver.close()
        driver.quit()

    if ret_err == True:
        sys.exit(1)

    return source
        

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Screenshot a website.')
    parser.add_argument('-u', dest='host', help='Website URL', required=True)
    parser.add_argument('-q', dest='query', help='URL Query', required=False)
    parser.add_argument('-p', dest='port', help='Port', required=False)
    args = parser.parse_args()

    take_screenshot(args.host, args.port, args.query)

