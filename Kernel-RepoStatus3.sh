# Kernel-RepoStatus3.sh - SplitConfig Enabled

# Source our config #
# Define our Config File
KRS_ConfigFile="$(pwd)/Kernel-RepoStatus.bfunc"

function KRS_SourceConfigFile() {
    # Source Our Config File
    if [ "-f" "$KRS_ConfigFile" ]; then
        # shellcheck source=/dev/null
        source "$KRS_ConfigFile"
    else
        echo "ERROR: Functions File $KRS_ConfigFile Not Found!"
        break
    fi



### Run Functions ###
DisplayBanner
GetCurrentReleaseVersion
Clean_Dnf
# PerformRepoQuery
RepoQueryTableGenerator
