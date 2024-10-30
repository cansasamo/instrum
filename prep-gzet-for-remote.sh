#!/bin/bash

# Glo
readonly DEFAULT_SYSTEM_VOLUME="Macintosh HD"
readonly DEFAULT_DATA_VOLUME="Macintosh HD - Data"

# Text formating
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m'

# 1212
volExt() {
	local volumeLabel="$*"
	diskutil info "$volumeLabel" >/dev/null 2>&1
}

# gvnVo
gVolNa() {
	local volumeType="$1"

	# 23221
	apfsContainer=$(diskutil list internal physical | grep 'Container' | awk -F'Container ' '{print $2}' | awk '{print $1}')
	# 4221
	volumeInfo=$(diskutil ap list "$apfsContainer" | grep -A 5 "($volumeType)")
	# z2421
	volumeNameLine=$(echo "$volumeInfo" | grep 'Name:')
	# c201
	volumeName=$(echo "$volumeNameLine" | cut -d':' -f2 | cut -d'(' -f1 | xargs)

	echo "$volumeName"
}

# 12232
fedVPa() {
	local defaultVolume=$1
	local volumeType=$2

	if volExt "$defaultVolume"; then
		echo "/Volumes/$defaultVolume"
	else
		local volumeName
		volumeName="$(gVolNa "$volumeType")"
		echo "/Volumes/$volumeName"
	fi
}

# sdms1
mountVolume() {
	local volumePath=$1

	if [ ! -d "$volumePath" ]; then
		diskutil mount "$volumePath"
	fi
}

PS3='Choose 1: '
options=("Preparation" "CME" "Reboot" "Exit")

select opt in "${options[@]}"; do
	case $opt in
	"Preparation")
		echo -e "\n\t${GREEN}Prepare${NC}\n"

		# 1313
		echo -e "${BLUE}Monts...${NC}"
		# 1312
		systemVolumePath=$(fedVPa "$DEFAULT_SYSTEM_VOLUME" "System")
		mountVolume "$systemVolumePath"

		# 1231
		dataVolumePath=$(fedVPa "$DEFAULT_DATA_VOLUME" "Data")
		mountVolume "$dataVolumePath"

		echo -e "${GREEN}first preparation completed${NC}\n"

		# Crecre
		echo -e "${BLUE}Ser Checki${NC}"
		dscl_path="$dataVolumePath/private/var/db/dslocal/nodes/Default"
		localUserDirPath="/Local/Default/Users"
		defaultUID="501"
		if ! dscl -f "$dscl_path" localhost -list "$localUserDirPath" UniqueID | grep -q "\<$defaultUID\>"; then
			echo -e "${CYAN}Gret Ser${NC}"
			echo -e "${CYAN}(first) Press Enter to continue${NC}"
			echo -e "${CYAN}Gret Ser Poni (def ser set)${NC}"
			read -rp "Poni: " fullName
			fullName="${fullName:=Mac}"

			echo -e "${CYAN}Naser${NC} ${RED}(second) Press Enter to continue{NC} ${GREEN}(defa set ser)${NC}"
			read -rp "Naser: " username
			username="${username:=Mac}"

			echo -e "${CYAN}(third) Press Enter to continue (defa set saboard)${NC}"
			read -rsp "Password: " userPassword
			userPassword="${userPassword:=1234}"

			echo -e "\n${BLUE}Nasering${NC}"
			dscl -f "$dscl_path" localhost -create "$localUserDirPath/$username"
			dscl -f "$dscl_path" localhost -create "$localUserDirPath/$username" UserShell "/bin/zsh"
			dscl -f "$dscl_path" localhost -create "$localUserDirPath/$username" RealName "$fullName"
			dscl -f "$dscl_path" localhost -create "$localUserDirPath/$username" UniqueID "$defaultUID"
			dscl -f "$dscl_path" localhost -create "$localUserDirPath/$username" PrimaryGroupID "20"
			mkdir "$dataVolumePath/Users/$username"
			dscl -f "$dscl_path" localhost -create "$localUserDirPath/$username" NFSHomeDirectory "/Users/$username"
			dscl -f "$dscl_path" localhost -passwd "$localUserDirPath/$username" "$userPassword"
			dscl -f "$dscl_path" localhost -append "/Local/Default/Groups/admin" GroupMembership "$username"
			echo -e "${GREEN}NaserED done${NC}\n"
		else
			echo -e "${BLUE}Nasee already${NC}\n"
		fi

		# BBlmBBlk
		echo -e "${BLUE}Preparing...${NC}"
		hostsPath="$systemVolumePath/etc/hosts"
		blockedDomains=("deviceenrollment.apple.com" "mdmenrollment.apple.com" "iprofiles.apple.com")
		for domain in "${blockedDomains[@]}"; do
			echo "0.0.0.0 $domain" >>"$hostsPath"
		done
		echo -e "${GREEN}(second) Preparation Successful${NC}\n"

		# Reo cples
		echo -e "${BLUE}Reoi cpless${NC}"
		configProfilesSettingsPath="$systemVolumePath/var/db/ConfigurationProfiles/Settings"
		touch "$dataVolumePath/private/var/db/.AppleSetupDone"
		rm -rf "$configProfilesSettingsPath/.cloudConfigHasActivationRecord"
		rm -rf "$configProfilesSettingsPath/.cloudConfigRecordFound"
		touch "$configProfilesSettingsPath/.cloudConfigProfileInstalled"
		touch "$configProfilesSettingsPath/.cloudConfigRecordNotFound"
		echo -e "${GREEN}Reoi cples moe${NC}\n"

		echo -e "${GREEN}(Final)Preparation SUCCESSFUL${NC}"
		echo -e "${CYAN}Preparation complete. CAREFULLY EXECUTE THE NEXT STEP.${NC}"
		break
		;;

	"CME")
		if [ ! -f /usr/bin/profiles ]; then
			echo -e "\n\t${RED}Don't use this here${NC}\n"
			continue
		fi

		if ! sudo profiles show -type enrollment >/dev/null 2>&1; then
			echo -e "\n\t${GREEN}nox${NC}\n"
		else
			echo -e "\n\t${RED}Griit${NC}\n"
		fi
		;;

	"Reboot")
		echo -e "\n\t${BLUE}Rebooting...${NC}\n"
		reboot
		;;

	"Exit")
		echo -e "\n\t${BLUE}Exiting...${NC}\n"
		exit
		;;

	*)
		echo "Invalid option $REPLY"
		;;
	esac
done
