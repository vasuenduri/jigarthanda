# RabbitMQ Management

## Overview
Rabbitmq-management directory contains actions workflow and bash script to purge the queues in rabbitmq cluster

* [choco_automation.ps1](choco_automation.ps1) and [choco_automation.bat](choco_automation.bat) install and configure Chocolatey for Business.
* set_choco_permissions.ps1 and set_choco_permissions.bat correctly set the permissions on the C:\ProgramData\Chocolatey folder, subfolders, and files

## Execution Flows - choco_automation
1. Add _Nexus_ repo as a source for Chocolatey
2. Installs the Chocolatey License as well as a few other Chocolatey packages
3. Installs the chocolatey extension package. There may be errors that cause this to fail, try to install it with the _--force_ switch
4. Installs the Chocolatey Agent service that will elevate the Choco command for the user
5. Installs the Chocolatey GUI

## Additional Notes
- The user can use the three choco commands "install, upgrade, uninstall"
- Chocolatey Agent service will only be used when the use of the choco command is not elevated.
- Moreover the script:
  - Stops warnings regarding non-elevated installs
  - Keeps users from uninstalling Chocolatey applications that they didn't install
  - Forces chocolatey to use the Chocolatey Agent "in the background" when running choco commands
  - Removes the original source (i.e. the community repo), otherwise the user will get 503 errors when running choco install commands
