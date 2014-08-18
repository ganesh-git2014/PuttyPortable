======================================
 Putty Session Generator Script
 Date:   2013/06/14
 Author: getkub
======================================
Pre-reqs - Need AutoIT software, which cannot be put into GITHUB. Need to download it separately 
AutoIT download - https://www.autoitscript.com/site/autoit/downloads/

How to Generate sessions for yourself
- Exit any Putty/SuperPutty Sessions you got Open
- Take a copy of the entire Directory Structure and contents to "C:\PuttyPortable"  (Create a directory if not existing)
- Remember to configure "SuperPutty" to point to  "C:\PuttyPortable\putty.exe"  # One time Configuration
- Amend C:\PuttyPortable\SessionConfig\Sample_ServerList.csv  with your Server list (Please follow the pattern already in the file)
- Link "Shortcut to AutoIt3.exe" to where you had AutoIt3.exe installed
- Run the "C:\PuttyPortable\Shortcut to AutoIt3.exe" and point it to use "C:\PuttyPortable\PuttySessionGenerator.au3"
- Voila !!  Start "SuperPutty" again and you can see all putty sessions well aligned with automated logins

* ======================================
* Automated Logins
* ======================================
To use automated logins, you need to configure public/private key. Documentation: http://www.ualberta.ca/CNS/RESEARCH/LinuxClusters/pka-putty.html

- Generate the priviate Key and Keep it safely. I would advise to keep outside this directory, so that next time when you overwrite it is not lost.
- Load the private key into "PAGEANT.exe" (provided in this directory)
- Open your sessions one by one and paste the public key  into ~/ssh/authorized_keys2  .Alternatively you can use "commands" window in SuperPutty to do across multiple servers at same time

publicKey='some_verylong_public_key_hereeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee'
mkdir -p ~/.ssh
echo $publicKey > ~/.ssh/authorized_keys2
chmod 600 ~/.ssh/authorized_keys2
Start using Putty/SuperPutty and you should be logging in automatically


* ======================================
* Technical Details if you are interested
* ======================================
* AutoIT
PuttySessionGenerator.au3		- Main Script to generate everthing. Require AUTOIT software

# Details
"ses" 							  - folder contains all the sessions for Putty
"SessionConfig" 			- Folder contains all Config
"SuperPutty"					- Contains SuperPutty Executable and configs/Sessions. 
