## Check all tools: right now, only rename
if ! command -v rename &> /dev/null
then
	echo "Command rename not found. On macOS, install it with:"
    echo "brew install rename"
    exit -1
fi

## Check if kamp directory exists
ORIGINAL_KAMP_KIT="original_kamp_kit"
if [ -d $ORIGINAL_KAMP_KIT ]; then
    ## If exists, git pull
    cd $ORIGINAL_KAMP_KIT;
    git pull
    cd ..
else
    ## Else, git clone
    git clone https://github.com/touchlab/KaMPKit.git $ORIGINAL_KAMP_KIT
fi

## Ask user for some project data
read -p 'Root folder name (without spaces): ' rootFolder
if [ -z "$rootFolder" ]; then
      echo "Cannot proceed without a valid project name"
      exit -1
fi

read -p 'Domain: ' domain
if [ -z "$domain" ]; then
      echo "Cannot proceed without a valid domain"
      exit -1
fi

read -p 'Company: ' company
if [ -z "$company" ]; then
      echo "Cannot proceed without a valid company"
      exit -1
fi

read -p 'Project name: ' projectName
if [ -z "$projectName" ]; then
      echo "Cannot proceed without a valid project name"
      exit -1
fi

iosProjectName="$(tr '[:lower:]' '[:upper:]' <<< ${projectName:0:1})${projectName:1}iOS"

## If root folder already exists, abort
if [ -d $rootFolder ]; then
    echo "Folder $rootFolder" already exits. Aborting.
    exit -1
fi

## Copy kamp directory in root folder
cp -r "$ORIGINAL_KAMP_KIT" "$rootFolder"
cd "$rootFolder"

## Delete useless files and dirs
rm CONTACT_US.md LICENSE.txt README.md azure/* docs/Screenshots/* docs/* kampkit.png tl2.png 2> /dev/null
rmdir azure docs/Screenshots docs

function clearPath {
	initialPath=$(pwd)
    cd $1
	mkdir -p "$domain/$company/$projectName"
	mv co/touchlab/kampkit/* "$domain/$company/$projectName/"
	rmdir "co/touchlab/kampkit" "co/touchlab" "co"
	cd $initialPath
}
### [Android] Rename files/folders
clearPath app/src/main/java

### [iOS] Rename files/folders
find . -depth -execdir rename "s/KaMPKitiOS/${iosProjectName}/g" '{}' \;

### [Shared] Rename files/folders
clearPath shared/src/androidTest/kotlin
clearPath shared/src/iosMain/kotlin
clearPath shared/src/commonMain/kotlin
clearPath shared/src/commonMain/sqldelight
clearPath shared/src/commonTest/kotlin
clearPath shared/src/iosTest/kotlin
clearPath shared/src/androidMain/kotlin

### [Android] Replace text
for file in $(grep -R -l --include \*.kt "co.touchlab.kampkit" .); do
	sed -i .bak "s/co\.touchlab\.kampkit/${domain}.${company}.${projectName}/g" $file
	rm "${file}.bak"
done

### [iOS] Replace text
### [Shared] Replace text
