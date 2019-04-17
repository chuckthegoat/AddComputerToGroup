#!/bin/bash
#
# Script taking a group name as an argument
# that adds the computer running the script
# to that group.
#

# Set the username, password, and URL for your JSS here
apiuser='apiusername'
apipass='apipassword'
apiUrl="/path/to/JSSResource/"

# Check if an argument has been given
if [ $# == 3 ]; then
	echo "Please specify a group"
	exit 0
fi

# Get the ID of the group
group=$4
groups=`curl -s --user $apiuser:$apipass -X GET $apiUrl"computergroups"`
groupId=`echo $groups | grep -o "<id>\([0-9]*\)<\/id><name>$group<\/name>" | sed "s/.*<id>\([0-9]*\)<\/id><name>$group<\/name>.*/\1/g"`

# Check to make sure that the given group is valid
if [ ! $groupId ]; then
	echo "Error: group not found"
	exit 0
fi

# Get the ID of the computer
computer=`/usr/local/bin/jamf getComputerName | sed 's/<computer_name>\(.*\)<\/computer_name>/\1/'`
computers=`curl -s --user $apiuser:$apipass -X GET $apiUrl"computers"`
computerId=`echo $computers | grep -o "<id>\([0-9]*\)<\/id><name>$computer<\/name>" | sed "s/.*<id>\([0-9]*\)<\/id><name>$computer<\/name>.*/\1/g"`

# Check to make sure the computer is in the JSS
if [ ! $computerId ]; then
	echo "Error: computer not found"
	exit 0
fi

echo "Adding computer $computerId to group $groupId"

# Add the computer to the group
data="<computer_group><computer_additions><computer><id>$computerId</id></computer></computer_additions></computer_group>"
curl -s -H "Content-type:application/xml" --data $data --user $apiuser:$apipass -X PUT $apiUrl"computergroups/id/"$groupId

exit 0
