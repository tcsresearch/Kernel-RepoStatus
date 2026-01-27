
# Define which Fedora releases to query
## TODO: Get current release from /etc/os-release and use below.
dists=(42 43 rawhide)

function GetCurrentReleaseVersion () {
# Display current running version.
# InstalledReleaseVer is determined by running 'eval' with cat, grep, and cut to only show the desired info.
#                      Run  Command              Filter Line        Filter Out First 9 Characters
InstalledReleaseVer="$(eval cat /etc/os-release | grep VERSION_ID | cut -c 12- )"
# cat /etc/os-release | grep VERSION_ID 
echo "Found Fedora Version: $InstalledReleaseVer. "
echo " "
}

function Clean_Dnf() {
# clean dnf
echo "Performing DNF Cleanup..."
dnf clean all > /dev/null
}

# perform query.
# TODO: disable -rc and other items.
# 	Also change use of $dists variable to use $InstalledReleaseVer.

function PerformRepoQuery() {
	echo "Performing Repo Query..."
	echo " "
	for repo in fedora{,-rc} fedora stable {fedora,stable}-rc mainline{-wo-mergew,} next; do
    	[[ "${repo}" =~ (fedora|next)$ ]] && unset repostring
    	repostring="${repostring} --repofrompath=kvr-${repo},https://download.copr.fedorainfracloud.org/results/@kernel-vanilla/${repo}/fedora-\${distro}-x86_64/"
    	( [[ "${repo}" =~ (fedora|fedora-rc) ]] && [[ "${fedorarc_done}" ]] ) && continue
    	for distro in $InstalledReleaseVer ; do
        	queryresult="$(eval dnf repoquery --quiet ${repostring} --disablerepo=* --enablerepo=kvr-* --latest-limit=1 -q kernel --arch x86_64 --qf '%{version}-%{release}')"
   	   	printf '%-20s %-10s %s\n' "${repo}" "${distro}" "${queryresult:-lookup failed}"
    	done
    	[[ "${repo}" == fedora-rc ]] && fedorarc_done="TRUE"
	done
}

### Run Functions ###
GetCurrentReleaseVersion
Clean_Dnf
PerformRepoQuery

