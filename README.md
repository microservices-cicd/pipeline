# Getting started with Openshift

Accessing Openshift will mostly work by two ways:

* using a browser to access the  Web Console, a container running on Openshift
* using the CLI with the `oc` tool

## Logging in via Browser

Please ensure your credentials are working by logging in. The platform link is supplied by your trainer or can be asked for. If it works, you should be greeted by the Openshift Web Console.

## Logging in via CLI

### Installing the oc client 

To install the `oc` tool, download the appropiate release from [Github](https://github.com/openshift/origin/releases). 

#### Linux & Mac
When you use Linux or Mac, exctract the `oc` and `kubectl` to a directory which is covered by your `PATH` variable. To ensure this happens, I use the following trick (tested on Ubuntu 16.04 and 18.04):

Add those lines to your `~/.bashrc` or create a file with this content to be loaded by all users (Bast Practice: I created `/etc/profile.d/user-bin-path.sh`):
```bash
# Expand $PATH to include the .bin directory in the users home
if [ -d "${HOME}/.bin" ]; then
    export PATH=$PATH:${HOME}/.bin/
fi
```
The create a folder called `.bin` in your home directory, e.g. via `mkdir ~/.bin`. Extract both filed mentioned above to this bin folder. Log out and log in again and check wether the new path got added to your `PATH` variable. You can check this by running `echo $PATH` from a command line. In that case you should no be able to issue a `oc` command.

#### Windows
When you are using Windows, make sure to have [Git for Windows](https://git-scm.com/download/win) installed. As part of the installation the Git Bash will be installed, which we will use for any commandline based action.

First of all we need to create a .bash_profile, to save all of our additions to the `PATH` variable. Therefore simply enter `touch ~/.bash_profile`. Open it within you favorite text editor. 
Here you will insert following content

If you have to connect from behind a proxy remove the # in front of the proxy lines and add the appropriate proxyaddress.

```bash
#export HTTP_PROXY=http://<proxy_ip>:<proxy_port>
#export HTTPS_PROXY=https://<proxy_ip>:<proxy_port>

export PATH=/C/Users/<YourUser>/<Projectpath>/oc-client:$PATH
```
Now exctract the `oc` and `kubectl` to the directory which we have just covered by the `PATH` variable.

### Adding autocompletion

The `oc` tools already supplies you with a bash script that can be used for autocompletion. Use following line to generate a bashscript which will offer auto completion.

```bash
oc completion bash > ~/<project-path>/oc-completion.sh
```

Now we will add another line to our `.bashrc`/`.bash_profile` (accodring to your setup).

Line to add:
```bash
source ~/<project-path>/oc_completion.sh
```
 After logging in again, I was now able to use oc autocompletion

### Logging in via oc client

Since we want to avoid storing credentials permanently on disk, we will obtain a *token*. This has a limited timeframe where it can be used. To obtain the token, login via Browser and click on your name in the upper right corner. Here click on *Copy Login Command* and issue the copied command into your shell. It should look like `oc login <WEB_ADDRESS> --token=<YOUR_TOKEN>`.

After that, issue `oc projects`

### Create your project

To create your project, issue `oc new-project m-cicd-dev` where *m-cicd-dev* is the project name. As projects have to be unique, your trainer may supply another project name or a naming schema. Please keep in mind to change the project name whenever needed through this tutorial

### Create the services

We recommend the following order when creating the services. However, the services can be placed in whatever order your want, this order is structured the way that you will an understanding of what is done in order to achive that specific goal and builds ontop of each other in terms of understanding.

1. [Creating the Carts](README_CARTS.md)
2. [Creating the Catalogue](README_CATALOGUE.md)
3. [Creating the Users](README_USERS.md)
4. [Creating the Orders](README_ORDERS.md)
5. [Creating the other small services](README_OTHERS.md)
6. [Creating the Frontend and exposing it](README_FRONTEND.md)
7. [Creating the CI/CD Pipeline](README_CICD.md)
8. [Creating the Loadtest](README_LOADTEST.md) **not working for now**
