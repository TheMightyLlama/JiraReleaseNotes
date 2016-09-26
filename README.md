
##DESCRIPTION
Produces a pdf of release notes generated from data produced by jira. Requires Jira to be configured to allow XML output. 

Originally developed for Mac and has not been tested elsewhere. 


##REQUIREMENTS:
* wkhtmltopdf | [download](http://wkhtmltopdf.org)
* jq | [download](http://stedolan.github.io/jq/download/)
* bash | Bash version 4 or above in order to use associative arrays

##COMPATIBILITY:
* JIRA: v6.0.8

##BASH UPGRADE GUIDES FOR MAC OS X
* [StackExchange: Patch bash on OSX in wake of Shellshock](http://security.stackexchange.com/questions/68202/how-to-patch-bash-on-osx-in-wake-of-shellshock)
* [StackExchange: Upgrading Bash via Homebrew](http://apple.stackexchange.com/questions/24632/is-it-safe-to-upgrade-bash-via-homebrew)
* [Gist: Install Bash Version 4 on MacOS X Using Brew](https://gist.github.com/samnang/1759336)


##SETUP:
 1. Change the username and password in config.cfg to your own.
 2. Change the jira api url in config.cfg to your own.
 3. Change the project code in config.cfg to your own.
 4. Change all instances of "your-jira-instance.com" to your own


##TO RUN:

Navigate to the folder containing: GetJiraReleaseIssues.sh

`$GetJiraReleaseIssues.sh -c "<fixVersion>"`

Where <fixVersion> is the alphanumeric version name described in: https://your-jira-instance.com/jira/browse/<project code>#selectedTab=com.atlassian.jira.plugin.system.project:versions-panel&subset=-1
