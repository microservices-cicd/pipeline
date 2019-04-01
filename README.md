# Getting started with Openshift

Accessing Openshift will mostly work by two ways:

* using a browser to access the  Web Console, a container running on Openshift
* using the CLI with the `oc` tool

## Logging in via Browser

Please ensure your credentials are working by logging in. The platform link is supplied by your trainer or can be asked for. If it works, you should be greeted by the Openshift Web Console.

## Logging in via CLI

### Installing the oc client 

To install the `oc` tool, download the appropiate release from [Github](https://github.com/openshift/origin/releases). When you use Linux or Mac, exctract the `oc` and `kubectl` to a directory which is covered by your `PATH` variable. To ensure this happens, I use the following trick (tested on Ubuntu 16.04 and 18.04):

Add those lines to your `~/.bashrc` or create a file with this content to be loaded by all users (in my case, i created `/etc/profile.d/user-bin-path.sh`):
```
# Expand $PATH to include the .bin directory in the users home
if [ -d "${HOME}/.bin" ]; then
    export PATH=$PATH:${HOME}/.bin/
fi
```
The create a folder called `.bin` in your home directory, e.g. via `mkdir ~/.bin`. Extract both filed mentioned above to this bin folder. Log out and log in again and check wether the new path got added to your `PATH` variable. You can check this by running `echo $PATH` from a command line. In that case you should no be able to issue a `oc` command.

### Adding autocompletion

The `oc` tools already supplies you with a bash script that can be used for autocompletion. For my Ubuntu System I used `oc completion bash > ~/oc-completion` and put the result file to `etc/bash_completion.d`. After logging in again, I was now able to use oc autocompletion

### Logging in via oc client

Since we want to avoid storing credentials permanently on disk, we will obtain a *token*. This has a limited timeframe where it can be used. To obtain the token, login via Browser and click on your name in the upper right corner. Here click on *Copy Login Command* and issue the copied command into your shell. It should look like `oc login <WEB_ADDRESS> --token=<YOUR_TOKEN`.

After that, issue `oc projects`

### Create your project

To create your project, issue `oc new-project m-cicd-dev` where *m-cicd-dev* is the project name. As projects have to be unique, your trainer may supply another project name or a naming schema. Please keep in mind to change the project name whenever needed through this tutorial

### Create the services

We recommend the following order when creating the services. However, the services can be placed in whatever order your want, the order is recommended for understanding.

1. [Creating the Carts](README_CARTS.md)
2. [Creating the Catalogue](README_CATALOGUE.md)
3. [Creating the Users](README_USERS.md)
4. [Creating the Orders](README_ORDERS.md)
5. [Creating the other small services](README_OTHERS.md)
6. [Creating the Frontend and exposing it](README_FRONTEND.md)
7. [Creating the CI/CD Pipeline](README_CICD.md)
8. [Creating the Loadtest](README_LOADTEST.md) **not working for now**
