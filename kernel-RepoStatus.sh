### Define Variables ###

# Define which Fedora releases to query
# Superceded by $InstalledReleaseVer, but kept here in case a query is desired for a different version other than what is installed.
dists="(42 43 rawhide)"

KRepoTool_Version="0.3"

# Define Repo Variables
Repo_BaseURL="https://download.copr.fedorainfracloud.org/results/@kernel-vanilla"
Repo_Arch="x86_64"

#########################################################################################################################################################################################
# FUNCTIONS #																																											#
#########################################################################################################################################################################################


function DisplayBanner() {
	echo "Kernel-vanilla Repo Query Tool - Version $KRepoTool_Version"
	echo " "
}

function GetCurrentReleaseVersion () {
	# Display current running version.
	# InstalledReleaseVer is determined by running 'eval' with cat, grep, and cut to only show the desired info.
	#                      Run  Command              Filter Line        Filter Out First 9 Characters
	InstalledReleaseVer="$(eval cat /etc/os-release | grep VERSION_ID | cut -c 12- )"
	echo "   Found Fedora Version: $InstalledReleaseVer. "
	echo " "
}

function Clean_Dnf() {
	# Clean DNF
	echo "   Performing DNF Cleanup..."
	dnf clean all > /dev/null
	echo " "
}

# perform query.
# TODO: disable -rc and other items.
#	Place inside a banner and add header descriptors at the top.

function PerformRepoQuery() {
	# echo "Performing Repo Query..."
	echo " "
	for repo in fedora{,-rc} fedora stable {fedora,stable}-rc mainline{-wo-mergew,} next; do
    	[[ "${repo}" =~ (fedora|next)$ ]] && unset repostring
    	
    	repostring="${repostring} --repofrompath=kvr-${repo},$Repo_BaseURL/${repo}/fedora-\${distro}-$Repo_Arch/"
	( [[ "${repo}" =~ (fedora|fedora-rc) ]] && [[ "${fedorarc_done}" ]] ) && continue
    	for distro in $InstalledReleaseVer ; do
        	queryresult="$(eval dnf repoquery --quiet ${repostring} --disablerepo=* --enablerepo=kvr-* --latest-limit=1 -q kernel --arch x86_64 --qf '%{version}-%{release}')"
   	   	printf '%-20s %-10s %s\n' "${repo}" "${distro}" "${queryresult:-lookup failed}"
    	done
    	[[ "${repo}" == fedora-rc ]] && fedorarc_done="TRUE"
	done
}

function RepoQueryTableGenerator() {
## TODO: Modify to use with PerformRepoQuery function.
# Define the format string with fixed widths and left alignment (%-Xs)
#   %-15s: left-align string in a 15-char width
#   %-8s: left-align string in an 8-char width
#   %-10s: left-align string in a 10-char width
#   \n: newline character
	# FORMAT="%-15s | %-8s | %-10s\n"
	FORMAT="%-20s %-10s %s\n"

# Print the header row
	printf "$FORMAT" "Repo Name" "Release" "Kernel Version"

# Print a separator line
	# printf -- '----------------+----------+------------\n'
	printf -- '--------------------+------+--------------------------------------------------\n'

# Print the data rows using the same format string
##	printf "$FORMAT" "Triangle" "red" "20"
##	printf "$FORMAT" "Oval" "dark blue" "65.66"
##	printf "$FORMAT" "Square" "orange" "0.70"
	PerformRepoQuery

# Print a separator line
        # printf -- '----------------+----------+------------\n'
        printf -- '--------------------+------+--------------------------------------------------\n'
}

#########################################################################################################################################################################################

### Run Functions ###
DisplayBanner
GetCurrentReleaseVersion
Clean_Dnf
# PerformRepoQuery
RepoQueryTableGenerator
