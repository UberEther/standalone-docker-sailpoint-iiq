SailPoint IdentityIQ Dockerized
================================

# Prerequisites

Please note that IdentityIQ is closed source so you first need to get a license for IdentityIQ.
To do this, go to https://community.sailpoint.com/ to download the software (identityiq-8.0.zip & 1_ssb-v6.1.zip).

The file identityiq-8.0.zip can currently be found at: https://community.sailpoint.com/t5/IdentityIQ-Server-Software/identityiq-8-0-zip/ta-p/79498

The file 1_ssb-v6.1.zip can currently be found at: https://community.sailpoint.com/t5/Services-Standard-Deployment/Services-Standard-Build-SSB-v6-1/ta-p/76056

Once you clone the repository, you will put the downloaded files into the src/ directory to get started.

This does not include **ANY** SailPoint proprietary code and can only be used if you get these binaries from Compass.

# Description

This installation will provide you a working instance of SailPoint IdentityIQ 8.0 running with OpenJDK and Tomcat 9 in a docker container.

An additional container is built utilizing mysql to host the IdentityIQ database and an Apache webserver proxying the connections back to Tomcat.

This project was heavily inspired by ssperling/sailpoint-iiq.

Container will run in background, IIQ will be run from mounted volume.

## Docker
Get started with docker you can follow our instructions here: https://github.com/UberEther/standalone-iiq/blob/master/uedocker/README.md

Some additional instructions on getting set up on a Windows 10 machine can be found here: https://github.com/UberEther/standalone-iiq/blob/master/uedocker/ue-docker-windows.txt

## Volumes
1. ./uedocker/volumes/app-logs => Contains the /ue/logs/tomcat directory with all the tomcat logs for troubleshooting.
2. ./uedocker/volumes/app-scripts => Contains scripts to bootstrap the database and also IIQ with the basic xml files.
3. ./uedocker/volumes/app-ue => Contains the /ue/iiq/tomcat/webapps/ue directory in a read-write capacity so you can make updates directly for testing.
4. ./uedocker/volumes/web-logs => Contains the /ue/logs/https directory with all the Apache logs for troubleshooting.

## Ports
Five ports are exposed:

 - 80: default Apache port.
 - 443: default Apache SSL port.
 - 3060: default Mysql port.
 - 8080: default Tomcat port.
 - 8009: default Tomcat debug port.

# How to build SailPoint IdentityIQ and run the docker containers

Clone this repository locally to your computer:

```git clone https://github.com/UberEther/standalone-iiq.git```

**First things first, please return to the top of this article and validate that you have placed the identityiq-8.0.zip and 1_ssb-v6.1.zip files into the ./src directory.**

We are huge proponents of SailPoint's Standard Services Build process. In fact, it's the first thing we setup when we go into a customer environment because it saves everyone so much time. It can be used to very quickly package up your SailPoint code and environment specific configuration files as part of a continuous integration and continuous delivery pipeline. Normally, one would set up SSB once per environment but we have included some of the files we use to be able to service multiple environments (and customers) out of a single build process.  

More on SSB and it's benefits can be found at: https://community.sailpoint.com/docs/DOC-4125

We utilize the SSB process to stage all of the code for our SailPoint deployments. To integrate your own existing code into the build process create a folder under `./ssb/components/<your folder name>` and then edit `./ssb/envconfig/local-dev/components.txt` to include the name of your folder. This is probably the quickest way to get your code into the builds and have *your* customized version of SailPoint up and running in the container.

## Building the Baseline War File
First we want to validate your war can actually build before we build the docker containers. To do this, go to `./ssb` and execute the `build.sh` script

This should copy and extract the SSB and IdentityIQ 8.0 files into the appropriate places and take you through the SSB build process for the local dev environment. If successful, you should see a message that says **BUILD SUCCESSFUL** at the end of the run. This is a great sign.

## Building the Containers and Deploying SailPoint IdentityIQ 8.0

Now that we've proven that IIQ 8.0 can build, it's time to actually build the containers.

Change directory into `../uedocker` and execute the `bootstrap.sh build` script.

This script will build the application war file again, download the baseline docker containers to your machine, create the IIQ database, deploy the application and start the containers with our custom configuration.

In about 5 minutes you'll have an entire running set of docker containers with IIQ 8.0 deployed in it ready to run.

## If you want to run Accelerator Pack 2.2.0 with IdentityIQ 8.0

Modify the build.properties file in ./ssb/envconfig/local-dev and add the following two lines:

deployAcceleratorPack=true
acceleratorPackVersion=2.2.0 {change your version number if necessary}
usingDbSchemaExtensions=true

Download the latest Accelerator Pack from Compass found here: https://community.sailpoint.com/t5/Accelerator-Pack/Accelerator-Pack/ta-p/77961

Accelerator_Pack-8.0.zip into the ./ssb/components/iiq8.0/base directory
Rename Accelerator_Pack-8.0.zip to Accelerator_Pack-8.0-2.2.0.zip

Edit the ./ssb/envconfig/local-dev/components.txt and add 'ap' to the second line of the file. It should have two lines when you are complete:

iiq8.0
ap

Run the `bootstrap.sh build` script and you're good to go.

###NOTE: From the Accelerator Pack 8.0 Release Notes
After installation and upon startup, there may be some errors similar to:
property x is not defined in ObjectConfig
These are innocuous errors that will not affect the functionality of the Accelerator Pack or IdentityIQ.

# Usage

To make your life easier, you can import the certificate from ICAM-HTTPD/local-dev.cer into your browser as a trusted certificate.

## Login
Go to https://dev.icam.local/ue/login.jsf
User: spadmin
Password: admin

By default we have given Tomcat limited resources to keep the memory sizes down, so it may take a few minutes for the container to warm up and no longer throw a 500 error.

# Additional Info
This is a great way to get developers up and running with IdentityIQ very quickly. These same principles can be extended to your integrated development, test and production environments. If you're looking to apply continuous integration, continuous delivery and docker or kubernetes based containers in your environment please reach out to us at [hello@uberether.com](mailto:hello@uberether.com) and we'd love to help you and your team be more efficient in your SailPoint development process.

To get an idea of what this might look like, here is what a typical CI/CD docker based deployment looks like for our customers:

![SailPoint IdentityIQ Docker CI/CD Process](https://uberether.com/images/Slide4.png)
