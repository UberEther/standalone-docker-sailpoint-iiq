Install Docker & Docker-Compose
    - Linux - Install and configure Docker and Docker-Compose

    - Mac (native) - Use https://docs.docker.com/engine/installation/mac/

    - Windows w/ HyperV - Use https://docs.docker.com/docker-for-windows/
        - WARNING: Requires Windows Pro AND you cannot use other virtualization once HyperV is enabled

    - Mac or Windows with VirtualBox - Install Docker-Toolbox 

    - Mac or Windows with Alternate Virtualization
        - Install Docker-Toolbox WITHOUT VirtualBox
        - Install the necessary driver from the list below:
            - Mac / Parallels: https://github.com/Parallels/docker-machine-parallels
            - Windows / VMWare Workstation: https://github.com/pecigonzalo/docker-machine-vmwareworkstation
        - Manually create a Docker host named "default" using docker-machine following the directions for your driver

Macs may need this fix to improve performace (certainly with virtual box, uncertain for native)
    - https://github.com/docker/for-mac/issues/668#issuecomment-250406582

Check your docker VM - ensure it has a reasonable number of cores and memory (say 2-4 cores and 4gb if possible)

Note your docker IP and set a local host entry:
    192.168.99.100 dev.icam.local ldap.icam.local saml.icam.local

########################################
Docker System Changes
########################################

Import ICAM-HTTPD/local-dev.cer as a trusted certificate in your browser

Edit your Docker VM to have more memory (at least 2gb, preferably 4gb) and at least 2 cores

# Extract WAR file. Copy WAR file to ./volume/app-alm and extract it.
cd volumes/app-ue
jar -xvf <war_file_name>.war

To just stop and start the containers
    docker-compose up
    docker-compose down

General dev pattern:
    Use SailPoint UI or debug pages to configure
    *** The following steps are a little slower, so try to batch several changes together ***
    Once you have built your IdentityIQ SSB artifact
    Unpack the WAR into volumes/app-ue
    Rebuild the environment and verify your changes

Test URLs:
    Sailpoint: https://dev.icam.local:8080/ue
    Sailpoint Debug: https://dev.icam.local:8080/ue/debug
    Tomcat: http://dev.icam.local:8080

Reminder: Logs are in the volumes folder!  No need to bash into the containers!

Reminder: Periodically purge volumes/app-logs and volumes-web-logs

#########################
# Some helpful commands:
docker ps
docker exec -it XXXXXXX bash
docker-compose exec -it app bash   # Requires fix for windows - see https://github.com/docker/compose/issues/3194

# DANGEROUS: Removes ALL containers and their associated volumes (good for cleanup)
docker rm -vf $(docker ps -aq)
# DANGEROUS: Removes ALL containers (good for cleanup)
docker volume rm $(docker volume ls -q)
#########################



