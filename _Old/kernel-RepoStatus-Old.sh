
# Define which Fedora releases to query
## TODO: Get current release from /etc/os-release and use below.
dists=(42 43 rawhide)

function GetCurrentReleaseVersion () {
# Display current running version.
cat /etc/os-release | grep VERSION_ID
echo " "
}

function Clean_Dnf() {
# clean dnf
dnf clean all > /dev/null
}

# perform query.
# TODO: disable -rc and other items.

function PerformRepoQuery() {
	echo "Performing Repo Query..."
	echo " "
	for repo in fedora{,-rc} fedora stable {fedora,stable}-rc mainline{-wo-mergew,} next; do
    	[[ "${repo}" =~ (fedora|next)$ ]] && unset repostring
    	repostring="${repostring} --repofrompath=kvr-${repo},https://download.copr.fedorainfracloud.org/results/@kernel-vanilla/${repo}/fedora-\${distro}-x86_64/"
    	( [[ "${repo}" =~ (fedora|fedora-rc) ]] && [[ "${fedorarc_done}" ]] ) && continue
    	for distro in ${dists[*]} ; do
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

