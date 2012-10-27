
# Here are some environment variables that are set to the default values.  
# If you want to install the required components comment out these values 
# and set them as environment variables on your computer.
JAVA_HOME="C:\Java\jdk1.7.0_05"
ANDROID_HOME="C:\qc_android\android-sdk"
ANT_HOME="C:\qc_android\apache-ant"

JAVA_TOOLS=$(cygpath -u "$JAVA_HOME")/bin
ANDROID_INSTALL=$(cygpath -u "$ANDROID_HOME")
ANT_INSTALL=$(cygpath -u "$ANT_HOME")
PATH=$JAVA_TOOLS:$ANT_HOME:$PATH

ANDROID_TOOLS="$ANDROID_SDK"/tools
ANDROID_PLATFORM_TOOLS="$ANDROID_INSTALL"/platform-tools

proj_run_output='Project to run: '
if [ -f lastRun.txt ];
then
	PREV_PROJECT_NAME=$(<lastRun.txt)
	proj_run_output='Project to run fdsafdsa:['$PREV_PROJECT_NAME'] '
fi

while [ ! $PROJECT_NAME ]
do
    echo $proj_run_output
    read PROJECT_NAME
	if [ ! $PROJECT_NAME ];
	then
		if [ $PREV_PROJECT_NAME ];
		then
			PROJECT_NAME=$PREV_PROJECT_NAME
		fi
	fi
done

echo ---------------$PROJECT_NAME-----------------

if ! [ -d $PWD/QCApplications/$PROJECT_NAME ];
then
    echo "No project '$PWD/$PROJECT_NAME' found."
    exit 1
fi

echo "$PROJECT_NAME" > lastRun.txt


while [ ! $BUILD_TYPE ]
do
    echo 'Build (r)elease or (d)ebug:[d] '
    read BUILD_TYPE
    if [[ "$BUILD_TYPE" != "r" ]] && [[ "$BUILD_TYPE" != "d" ]];
    then
        BUILD_TYPE='d'
        echo 'Building debug version'
    fi
    if [[ "$BUILD_TYPE" == "r" ]]
    then
        BUILD_TYPE="release"
    else
        BUILD_TYPE="debug"
        echo -------------Updating Android Keystore------------------------
        # remove the debug keystore if it exists.  This will keep it from expiring.           
        if [ -f debug.keystore ]; then               
			echo "Updating keystore."               
        rm debug.keystore           
        else               
			echo "First build.  Creating keystore."           
        fi               
        # regenerate the debug keystore               
        # keytool is included in the standard JDK install               
        "$JAVA_TOOLS"/keytool.exe -genkey -v -storepass android -alias android -keypass android -keystore debug.keystore -validity 2000 -dname 'CN=Android Debug,O=Android,C=US' 
    fi
    
done
pwd
#read bundle id from file 
cd QCApplications/$PROJECT_NAME
BUNDLE_ID=$(<bundle_id.txt)
cd ../..

echo -------------Compiling and assembling application $PROJECT_NAME------------------------  
pwd
cd QCApplications/$PROJECT_NAME/build


if [ -d $PWD/bin ];
then
    rm -rf bin
fi
echo -------------Building------------------------


"$ANT_INSTALL"/bin/ant.bat $BUILD_TYPE 



echo -------------Initializing emulator------------------------
#androidSDK='/Developer/androidSDK'
# see if an emulator is running or a device is connected.
foundDevicesAndEmulators=$("$ANDROID_PLATFORM_TOOLS"/adb devices)

FoundEmulator=$("$ANDROID_PLATFORM_TOOLS"/adb devices| grep -v devices | grep emulator)           


FoundDevice=$("$ANDROID_PLATFORM_TOOLS"/adb devices| grep -v devices | grep -v emulator)           

Found=$FoundDevice              
if [ -z $Found ]; then               
    echo 'checking emulator'   
    Found=$FoundEmulator               
fi               

Found=${Found%%device*}               
Found=$Found | sed 's/ //g' 

if [ -z $Found ]; then               
echo 'No device or emulator found on which to install the application.  If you wish to run on a device plug it in.  If you want to run on an emulator start it prior to building.'               

exit 1               
#else 
#if [ -z $FoundDevice ]; then                   
#$androidSDK/platform-tools/adb -s $Found logcat -c      

#bring the found emulator to the front
#$HOME/Library/Developer/Xcode/Templates/Application/QC\ Hybrid\ Application.xctemplate/appswitch -a emulator-arm
#nircmd win activate "$FoundDevice"
fi

INSTALLATION_FILE_NAME=$(cygpath -aw .)/bin/$PROJECT_NAME-debug.apk
#INSTALLATION_FILE_NAME=


echo -------------un-installing $BUNDLE_ID from $Found---------------------- 
"$ANDROID_PLATFORM_TOOLS"/adb -s $Found uninstall $BUNDLE_ID               
              
echo -----------installing $INSTALLATION_FILE_NAME-----------------  



echo "installing: $INSTALLATION_FILE_NAME found: $Found"
"$ANDROID_PLATFORM_TOOLS"/adb -s $Found install -r "$INSTALLATION_FILE_NAME" 

ACTIVITY_NAME=${PROJECT_NAME// /};
echo "-------------launching $BUNDLE_ID/$ACTIVITY_NAME--------------"


"$ANDROID_PLATFORM_TOOLS"/adb -s $Found shell am start -a android.intent.action.MAIN -n $BUNDLE_ID/.$ACTIVITY_NAME                            
#echo -------------launching debugger--------------               
#$androidSDK/platform-tools/adb -s $Found logcat -f logfile.txt *:V &               
echo -------------launch complete-------------               

exit 0
                    