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

Save  "http-screenshot.nse", "screenshot.py", and "nmap-bootstrap.xsl" to a separate folder.

*Example how to execute scan*

nmap --script=[folder location where scripts got saved] -sV -n -v --defeat-rst-ratelimit --host-timeout 600s --stats-every 10s [subnet to be scanned]

If folder where scripts are located is /home/someuser/scripts and scanned network is 192.168.1.0/24, correct syntax to run nmap is:

**nmap --script=/home/someuser/scripts/ -sV -n -v --defeat-rst-ratelimit --host-timeout 600s --stats-every 10s -oA report 192.168.1.0/24**


-n no DNS name resolving.
--defeat-rst-ratelimit option works around rate-limiting of the target's responses on closed ports by allowing inaccuracies in differentiating between closed and filtered ports. It does not affect packet rates or open port detection.

--host-timeout 600s (Give up on slow target hosts).

The script drops all screenshots in the current directory.

To create nice looking HTML report, embedding produced screenshots:

**xsltproc -o report.html nmap-bootstrap.xsl report.xml**


Have fun.
