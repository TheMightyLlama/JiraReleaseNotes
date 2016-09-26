#!/bin/bash

##########################################################################################
#TODO:
##########################################################################################
#Add link to jira search function
#Github Branch
#Add nexus builds?
##########################################################################################
#This script requires a local installation of jq: http://stedolan.github.io/jq/
##########################################################################################

ACTION=$1
JIRA_FIXVERSION=$2;
EMAIL_RECIPIENT=$3;
BUG_COUNT=0;
TASK_COUNT=0;
STORY_COUNT=0;
RELEASE_DATE=0;
CLOSED_STORY_COUNT=0;
CLOSED_BUG_COUNT=0;
CLOSED_TASK_COUNT=0;
OPEN_STORY_COUNT=0;
OPEN_BUG_COUNT=0;
OPEN_TASK_COUNT=0;

#Returns the fixVersionID of the version passed to the script
function getFixVersionID
{

	fixVersionQuery=${JIRA_HOSTNAME}'project/'${PROJECT_CODE}'/versions?';
	fixVersionID=`curl -u $JIRA_USERNAME:$JIRA_PASSWORD -X GET -H "Content-Type: application/json" --insecure --silent $fixVersionQuery |jq '.[] | {id,name,userReleaseDate} | select(.name=='\""${JIRA_FIXVERSION}"\"') | .["id"]'`; 
	echo $fixVersionID;
}

function getAllFixVersions
{

    fixVersionQuery=${JIRA_HOSTNAME}'project/'${PROJECT_CODE}'/versions?';
    fixVersionID=`curl -u $JIRA_USERNAME:$JIRA_PASSWORD -X GET -H "Content-Type: application/json" --insecure --silent $fixVersionQuery |jq '.[] | {id,name,userReleaseDate} | .["name"]' > output/json/AllFixVersions.json`;   
    #echo $fixVersionID;
}

#Returns the fixVersion Release Dateof the version passed to the script
function getFixVersionReleaseDate
{

	releaseDateQuery=${JIRA_HOSTNAME}'project/'${PROJECT_CODE}'/versions?';
	releaseDate=`curl -u $JIRA_USERNAME:$JIRA_PASSWORD -X GET -H "Content-Type: application/json" --insecure --silent $releaseDateQuery |jq '.[] | {id,name,userReleaseDate} | select(.name=='\""${JIRA_FIXVERSION}"\"') | .["userReleaseDate"]'`; 
    releaseDate=`echo ${releaseDate} | tr / -`;
    releaseDate="${releaseDate%\"}"
    releaseDate="${releaseDate#\"}"

    if [ $releaseDate != "null" ]
        then

        releaseDate=`date -j -f "%d-%b-%y" ${releaseDate} +"%Y-%m-%d"`;

    fi
    

	echo $releaseDate;

}

#Returns all issues closed in version
function getAllIssues ()
{
#Bugs = 1
#Story = 8
#Task = 3
	
	#Define fixVersion http query
	fixVersionQuery=${JIRA_HOSTNAME}'search?jql=project="'${PROJECT_CODE}'"+AND+fixVersion='"$(getFixVersionID)"'+ORDER+BY+status+ASC&maxResults=500'; #%22ON%22+AND+fixVersion=14024

	#Get all issues for version 'x'
	#Put them into file 'FullClosedIssueList.json'#, 
	`curl -u $JIRA_USERNAME:$JIRA_PASSWORD -X GET -H "Content-Type: application/json" --insecure --silent $fixVersionQuery |jq '.["issues"] | map({key: .key, type: .fields.issuetype.name, typeid: .fields.issuetype.id, status: .fields.status.name, summary: .fields.summary, closedDate: .fields.resolutiondate, flag: .fields.customfield_10170[0].value}) | map(select(.typeid=="1", .typeid=="8", .typeid=="3"))' >  output/json/FullIssueList.json`; 	

}


#Separates issues into relevant json files
function separateIssues () {

    ############################
    #Closed Issues Of All Types#
    ############################

    #Closed Issues
    `jq -s '.[] | map(select(.status=="Closed"))' <  output/json/FullIssueList.json >  output/json/FullClosedIssueList.json`;

    #Closed Stories
    `jq -s '.[] | map(select(.typeid=="8"))' <  output/json/FullClosedIssueList.json >  output/json/ClosedStoriesList.json`;

    #Closed Bugs
    `jq -s '.[] | map(select(.typeid=="1"))' <  output/json/FullClosedIssueList.json >  output/json/ClosedBugsList.json`;

    #Closed Tasks
    `jq -s '.[] | map(select(.typeid=="3"))' <  output/json/FullClosedIssueList.json >  output/json/ClosedTasksList.json`;

    ############################
    #Open Issues Of All Types  #
    ############################

    #Open Issues
    `jq -s '.[] | map(select(.status!="Closed"))' <  output/json/FullIssueList.json >  output/json/FullOpenIssueList.json`;

    #Open Stories
    `jq -s '.[] | map(select(.typeid=="8"))' <  output/json/FullOpenIssueList.json >  output/json/OpenStoriesList.json`;

    #Open Bugs
    `jq -s '.[] | map(select(.typeid=="1"))' <  output/json/FullOpenIssueList.json >  output/json/OpenBugsList.json`;

    #Open Tasks
    `jq -s '.[] | map(select(.typeid=="3"))' <  output/json/FullOpenIssueList.json >  output/json/OpenTasksList.json`;


    ############################
    #Blocked Issues            #
    ############################

    #Blocked Issues
    `jq -s '.[] | map(select(.flag!=null))' <  output/json/FullIssueList.json >  output/json/FullBlockedIssueList.json`;

}

function getIssueCounts () {

    CLOSED_STORY_COUNT=`jq '. | length'  output/json/ClosedStoriesList.json`;
    CLOSED_BUG_COUNT=`jq '. | length'  output/json/ClosedBugsList.json`;
    CLOSED_TASK_COUNT=`jq '. | length'  output/json/ClosedTasksList.json`;

    OPEN_STORY_COUNT=`jq '. | length'  output/json/OpenStoriesList.json`;   
    OPEN_BUG_COUNT=`jq '. | length'  output/json/OpenBugsList.json`;
    OPEN_TASK_COUNT=`jq '. | length'  output/json/OpenTasksList.json`;

}

#Returns all issues in version which were moved this week
function getAllMovedIssues ()
{
#Bugs = 1
#Story = 8
#Task = 3
	
	#Define fixVersion http query
	fixVersionQuery=${JIRA_HOSTNAME}'search?jql=project="ON"+AND+status+changed+after+startOfWeek()+AND+type+not+in+("Sub-task","Fault","Epic")+AND+fixVersion='"$(getFixVersionID)"'+order+by+type+asc+,+status+asc'; #%22ON%22+AND+fixVersion=14024

	#Get all issues for version 'x'
	#Put them into file 'FullClosedIssueList.json'
	`curl -u $JIRA_USERNAME:$JIRA_PASSWORD -X GET -H "Content-Type: application/json" --insecure --silent $fixVersionQuery |jq '.["issues"] | map({key: .key, type: .fields.issuetype.name, typeid: .fields.issuetype.id, status: .fields.status.name, summary: .fields.summary})' >  output/json/FullMovedIssueList.json`; 	

}

function getChartData () {
	
	
	chartData="[";

	chartDate=$(date -j -v -1d -f "%Y-%m-%d" "$(chartStartsAt)" +%Y-%m-%d) &>/dev/null;
	#echo $chartDate;

	now=`date +%Y-%m-%d`;
	#echo $now;

	issueCount=`jq '. | length'  output/json/FullIssueList.json`;
	
	countTotal=0;
	declare -A dataArray;

 	while [ ! "${chartDate}" \> "${now}" ]
  		do 
  			chartData="$chartData {";
   			
   			#echo $chartDate

   			chartData="$chartData \"key\" : \"$chartDate\"";
   			chartData="$chartData ,";

  			dayTotal=`grep -c "${chartDate}" output/json/FullIssueList.json`;
  			#echo $dayTotal;

  			((closedSum = issueCount - countTotal - dayTotal)) &>/dev/null;
  			#echo $closedSum;

  			chartData="$chartData \"value\":\"$closedSum\"";

  			((countTotal = countTotal + dayTotal))  &>/dev/null;

  			#dataArray[${chartDate}]="${dayTotal} + ${issueCount}";
  			dataArray[${chartDate}]=${closedSum};

  			#echo ${chartDate} --- $dataArray[$chartDate]
  			chartData="$chartData },";
  			chartDate=$(date -j -v +1d -f "%Y-%m-%d" "${chartDate}" +%Y-%m-%d) &>/dev/null;

  			if [ "$closedSum" == 0 ]; then
      			break
  			fi
 		done

 		chartData=${chartData/%?/};

 		chartData="$chartData ]";

 		echo "$chartData" > output/json/chartData.json;

}


function createVersionJSON () {
	eval fixVersion=$1;
	eval releaseDate=$2;
	closedBugCount=$3;
	openBugCount=$4;
	closedTaskCount=$5;
	openTaskCount=$6;
	closedStoryCount=$7;
	openStoryCount=$8;
    startDate=$9;
    averageClosures=${10};
    averageTimeInProgress=${11};

	`echo -e "{\"FixVersion\":\""${fixVersion}"\",\"ReleaseDate\":\"$releaseDate\",\"ClosedBugCount\":\""$closedBugCount"\",\"OpenBugCount\":\""$openBugCount"\",\"ClosedTaskCount\":\""$closedTaskCount"\",\"OpenTaskCount\":\""$openTaskCount"\",\"ClosedStoryCount\":\""$closedStoryCount"\",\"OpenStoryCount\":\""$openStoryCount"\",\"StartDate\":\""$startDate"\",\"AverageClosures\":\""$averageClosures"\",\"AverageTimeInProgress\":\""$averageTimeInProgress"\"}" >  output/json/ProjectVersion.json`;

}



function removeOldFiles () {

	#Remove all files in  output/json/ sub-directory
	`rm -rfv  output/json/*.* &>/dev/null`;
	echo "Clearing old data";

}

function chartStartsAt () {

    nowDate=`date +%Y-%m-%d`;

	CHART_START=`jq 'map(.closedDate | values) | min' < output/json/FullIssueList.json`;
	CHART_START="${CHART_START//\"}"

    if [ "${CHART_START}" == "null" ] ; then
        CHART_START=$nowDate;
    elif [ "${CHART_START}" != "null" ] ; then
        CHART_START="${CHART_START//\"}";
        CHART_START="${CHART_START%T*}";
    fi

	echo "${CHART_START}";

}

function numberOfWeeksInVersion () {

    startDate=$(chartStartsAt);
    endDate=$(getFixVersionReleaseDate);

    
    nowDate=`date +%Y-%m-%d`;
 
    
    if  [ "${endDate}" == "null" ] ; then
        

        numberOfWeeks=$((`date -jf %Y-%m-%d $nowDate +%s` - `date -jf %Y-%m-%d $startDate +%s`));
        #numberOfDays=$(((`date -jf %Y-%m-%d $nowDate +%s` - `date -jf %Y-%m-%d $startDate +%s`)/86400));
        numberOfWeeks=$((numberOfWeeks/604800));

        if [ $numberOfWeeks == 0 ] ; then

            numberOfWeeks=1;
        fi
        
        

    elif [ "${endDate}" != "null" ] ; then

        numberOfWeeks=$((`date -jf %Y-%m-%d $endDate +%s` - `date -jf %Y-%m-%d $startDate +%s`));
        #numberOfDays==$(((`date -jf %Y-%m-%d $endDate +%s` - `date -jf %Y-%m-%d $startDate +%s`)/86400));
        numberOfWeeks=$((numberOfWeeks/604800));

        if [ $numberOfWeeks == 0 ] ; then

            numberOfWeeks=1;
        fi

        

    fi
    

    echo $numberOfWeeks;

}

function getAverageClosures () {

    closedStoryCount=$CLOSED_STORY_COUNT;
    closedTaskCount=$CLOSED_TASK_COUNT;
    closedBugCount=$CLOSED_BUG_COUNT;

    numberOfWeeksInVersion=$(numberOfWeeksInVersion);
 
    totalIssuesClosed=$((closedStoryCount+closedTaskCount+closedBugCount));
    averageIssuesClosed=$((totalIssuesClosed/numberOfWeeksInVersion));

    echo $averageIssuesClosed;

}

function printHelp () {

	cat << EOF
${bold}USAGE:${reset}
./GetJiraReleaseIssues -c "<version>"

This script will generate the Release Notes for a given <version> or list all the available <version>.
	
${bold}OPTIONS:${reset}
${bold}-h${reset}               Shows this message
${bold}-l${reset}               Lists all available <version>
${bold}-c "<version>"${reset}   Creates the Release Note for a <version>
	
EOF
}

function printStatus () {
    string=$1;
    status=$2;

    lineLength=`tput cols`;
    stringLength=${#string};
    statusLength=${#status};

    periodLength=$((lineLength - stringLength - statusLength));
    
    printf "${string}";
    printf '%0.s.' $(seq 1 $periodLength);
    

    if [[ ${status} = "OK" ]] ; then
        printf "${green}${status}${reset}";
    fi

    if [[ ${status} = "NOK" ]] ; then
        printf "${red}${status}${reset}";
    fi

}

function checkDependencies () {

    echo "${bold}CHECKING DEPENDENCIES:${reset}"

    checkBashVersion;
    checkWkhtmltoPDFVersion;
    checkjqVersion;
    echo "";
}

function checkBashVersion () {
	IN=$BASH_VERSION;
	while IFS='.' read -ra FIELDS; do
		if ( [ "${FIELDS[0]}" -le 4 ] && [ "${FIELDS[1]}" -lt 3 ] ); then

            printStatus "bash" "NOK";
			echo "${red}Bash version $BASH_VERSION too old, this script needs at least Bash-4.3${reset}";
			exit 1;
		fi

        bashVersion=`echo $BASH_VERSION`;
        printStatus "bash ${bashVersion}" "OK";
	done <<< "$IN"
}

function checkWkhtmltoPDFVersion () {

    

    if type wkhtmltopdf &>/dev/null; then
        
        wkhtmltopdfVersion=`wkhtmltopdf -V`;
        printStatus "${wkhtmltopdfVersion}" "OK";

    else
        printStatus "wkhtmltoPDF" "NOK";
        echo "${red}wkhtmltopdf is not installed. To download go to: http://wkhtmltopdf.org${reset}";
        exit 1;
    fi
}

function checkjqVersion () {

    

    if type jq &>/dev/null; then
        jqVersion=`jq -V`;
        printStatus "${jqVersion}" "OK";
        
    else
        printStatus "jq" "NOK";
        echo "${red}jq is not installed. To download go to: http://stedolan.github.io/jq/${reset}";
        exit 1;
    fi
}

##########################################################################################
#			MAIN								                                         #
##########################################################################################

##########################################################################################
#           COLOUR VALUES                                                                #
##########################################################################################
red=`tput setaf 1`
green=`tput setaf 2`
white=`tput setaf 7`
blue=`tput setaf 4`
bold=`tput bold`
reset=`tput sgr0`
#echo "${red}red text ${green}green text${reset}"

##########################################################################################
# Check environment programs existence and version			                    		 #
##########################################################################################

checkDependencies;


##########################################################################################
# Check args passed to the script						                            	 #
##########################################################################################

if [[ $# -eq 0 ]] ; then 
    echo "";
	printHelp;
	exit 1;
fi

if [[ ! $ACTION =~ ^-. ]] ; then
    echo "";
	printHelp;
	exit 1;
fi 

if [[ ${#ACTION} -gt 2 ]] ; then
    echo "";
	printHelp;
	exit 1;
fi

while getopts “hlc:” ACTION; do
	case $ACTION in
		c)		echo "";
                echo "${bold}COLLECTING DATA: ${JIRA_FIXVERSION}${reset}"
				break
				;;
		l)		getAllFixVersion
				exit 0
				;;
		h)		echo "";
                printHelp
				exit 0
				;;
		?)		echo "";
                printHelp
				exit 1
				;;
	esac
done

if [ -n "$JIRA_VERSION" ]
then
     printHelp;
     exit 1;
fi						

##########################################################################################
# LOAD CONFIG									 	 #
##########################################################################################

CONFIGFILE="config.cfg"
eval $(sed '/:/!d;/^ *#/d;s/:/ /;' < "$CONFIGFILE" | while read -r key val
do
    #verify here
    #...
    str="$key='$val'";
    echo "$str";
done)
#echo =$JIRA_USERNAME= =$JIRA_PASSWORD= =$JIRA_HOSTNAME= #here are defined

##########################################################################################
# Remove old files									 #
##########################################################################################
removeOldFiles;

##########################################################################################
# OBTAIN AND PARSE DATA									 #
##########################################################################################

getAllFixVersions;
echo "Retrieving Fix Version ID";
fixVersionID=$(getFixVersionID);


if [ -z "$fixVersionID" ]; then

    echo "${red}The version name you provided does not match any known versions exactly. Please choose a version from the below list.";
    name=`echo $JIRA_FIXVERSION | sed 's/[^a-zA-Z]//g'`;
    echo "Versions whose name matches: ${name} ${reset}";
    grep ${name} < output/json/AllFixVersions.json | sort -d;
    

    exit 1;

fi

getAllIssues;
getAllMovedIssues;

echo "Retrieving issues list";

separateIssues;

getChartData;

echo "Retrieving chart data";

getIssueCounts;

RELEASE_DATE=$(getFixVersionReleaseDate);
CHART_START=$(chartStartsAt);
AVERAGE_CLOSURES=$(getAverageClosures);

createVersionJSON "\${JIRA_FIXVERSION}" $RELEASE_DATE $CLOSED_BUG_COUNT $OPEN_BUG_COUNT $CLOSED_TASK_COUNT $OPEN_TASK_COUNT $CLOSED_STORY_COUNT $OPEN_STORY_COUNT $CHART_START $AVERAGE_CLOSURES;

# {"FixVersion":"HTML5 - 2.1.0","ReleaseDate":"8","ClosedBugCount":"8","OpenBugCount":"12","ClosedTaskCount":"2","OpenTaskCount":"4","ClosedStoryCount":"3","OpenStoryCount":"2015-01-30","StartDate":"4","AverageClosures":"","AverageTimeInProgress":"","ForecastDeliveryDate":""}

##########################################################################################
# Generate PDF Report									 #
##########################################################################################

    fileName="output/reports/"${JIRA_FIXVERSION}".pdf";

    if [ ! -e "$fileName" ] ; then
        touch "$fileName";
    fi

    if [ ! -w "$fileName" ] ; then
        rm "$fileName";
    fi

echo "";
echo "${bold}GENERATING RELEASE NOTES: ${JIRA_FIXVERSION}${reset}";

`wkhtmltopdf --no-stop-slow-scripts --javascript-delay 10000 cover output/cover.html toc --footer-font-size 8 --footer-left "Orange Vallee Report Generator by Christian Macedo" --footer-line output/template.html "$fileName"`;
`open "$fileName"`;

##########################################################################################
# Generate Report Time Stamp								 #
##########################################################################################

exit 0;