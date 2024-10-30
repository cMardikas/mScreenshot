# mScreenshot
A small script to automatically generate http,https screenshots from a nmap scan. 

Original script was made by Ryan Wincey (https://www.securifera.com/blog/2019/06/11/http-screenshots-with-nmap-chrome-and-selenium/).
Script is simplified and updated for Python3.

* Required packages Nmap, Python3, Selenium, Chromium & Chromium driver.

*How to install on Debian 12* 

- Nmap

sudo apt install nmap

- python3 and selenium 

sudo apt install python3 
sudo apt install python3-pip
sudo pip3 install selenium

- chromium & chromedriver

sudo apt install chromium
sudo apt install chromium-driver

-Screenshot scripts

Save  "http-screenshot.nse", "screenshot.py" to a separate folder.

*Example how to execute scan*

nmap -Pn -n  --script=[folder location where scripts got saved] -sV -v [subnet to be scanned]

The script drops all screenshots in the current directory.

