
# Here are the default environment variable values.  If you have installed in other places
# comment these lines and define environment variables on your computer.

ANDROID_HOME="C:/qc_android/android-sdk"

echo $ANDROID_HOME


#get the name of the application 
while [ ! $PROJECT_NAME ]
do
    echo 'Project Name: '
    read PROJECT_NAME
done
cd "QCApplications"
rm -rf $PROJECT_NAME
mkdir $PROJECT_NAME
cd $PROJECT_NAME

#get the bundle identifier 
while [ ! $BUNDLE_ID ]
do
    echo 'Package (ex. com.mycompany): '
    read BUNDLE_ID
done
BUNDLE_ID="$(tr [A-Z] [a-z] <<< "$BUNDLE_ID")"
echo $BUNDLE_ID > bundle_id.txt

#get the Android version 
while [ ! $ANDROID_VERSION ]
do
    echo 'Android Version: (1 - 15): '
    read ANDROID_VERSION

    if ! [ $ANDROID_VERSION ]
    then
        continue
    fi

    if ! [[ $ANDROID_VERSION =~ ^[0-9]+$ ]]
    then
        echo 'Android Version must be an integer.'
        ANDROID_VERSION=''
        echo $ANDROID_VERSION
        continue
    fi
    
    if ! [ $ANDROID_VERSION -ge 1 ] || ! [ $ANDROID_VERSION -le 15 ]
    then
        echo $ANDROID_VERSION is an invalid value. The valid range is [1-15]
        ANDROID_VERSION=''
        continue
    fi
done


   
echo ---------------Creating Android Project $PROJECT_NAME------------------

androidSDK=$ANDROID_HOME 
echo ----------------Clearing old build----------------               
rm -rf build           

echo ----------------Copying standard files----------------               
#copy the default android_build directory and other standard files               
#from the template directory into the current directory               
cp -R ../../QCAndroidSetup .

mv QCAndroidSetup build

cd build
touch assets/functions.js
touch assets/mappings.js

echo -e '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">\n<html>\n<head>\n<title>QCXcodeTemplate</title>\n<meta http-equiv="content-type" content="text/html; charset=utf-8">\n<meta name="viewport" content="width=device-width, minimum-scale=1.0, maximum-scale=1.6">\n<meta name="apple-mobile-web-app-capable" content="YES">\n<link rel="stylesheet" href="main.css">\n<script type="text/javascript" src="SetupQC.js" charset="utf-8"></script>\n<script type="text/javascript" src="main.js" charset="utf-8"></script>\n</head>\n<body onload="load();">\n\n</body>\n</html>' >assets/index.html

echo -e 'body {\n\tmargin: 0px;\n\tmin-height: 356px;\n\tfont-family: Helvetica;\n\tbackground-color:white;\n}' >assets/main.css

echo -e 'function load(){\n\n}' >assets/main.js
rm -rf src/org

PACKAGE_PATH=${BUNDLE_ID//.//}               
mkdir -p src/$PACKAGE_PATH

ACTIVITY_NAME=${PROJECT_NAME// /};
echo ----------------Building $ACTIVITY_NAME.java----------------             
echo 'package '$BUNDLE_ID'; import org.quickconnectfamily.hybrid.QCAndroid; import org.quickconnectfamily.hybrid.R; import android.app.Activity; import android.os.Bundle; public class '$ACTIVITY_NAME' extends QCAndroid { @Override public void onCreate(Bundle theBundle) {  super.onCreate(theBundle); } }' > src/$PACKAGE_PATH/$ACTIVITY_NAME.java

echo ----------------Building AndroidManifest.xml                                 
activityName=${EXECUTABLE_NAME// /};                              
#write out the AndroidManifest.xml file contents           
echo '<?xml version="1.0" encoding="utf-8"?><manifest xmlns:android="http://schemas.android.com/apk/res/android" package="'$BUNDLE_ID'" android:versionCode="'$ANDROID_VERSION'" android:versionName="1.0"><uses-sdk android:minSdkVersion="'$ANDROID_VERSION'"/><uses-permission android:name="android.permission.INTERNET" /><uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"></uses-permission><uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"></uses-permission><uses-permission android:name="android.permission.READ_PHONE_STATE"/><uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/><application android:icon="@drawable/icon" android:label="@string/app_name"><activity android:name="'$ACTIVITY_NAME'" android:label="@string/app_name" android:screenOrientation="portrait"><intent-filter><action android:name="android.intent.action.MAIN" /><category android:name="android.intent.category.LAUNCHER" /></intent-filter></activity><uses-library android:name="com.google.android.maps" /></application></manifest>' > AndroidManifest.xml

echo ----------------Building local.properties--------------
#write out the local.properties file contents
echo -e 'sdk.dir='$ANDROID_HOME'\nbuild.sysclasspath=last' >local.properties

echo ----------------Building strings.xml----------------               
#write out the strings.xml file contents               
echo '<?xml version="1.0" encoding="utf-8"?><resources><string name="app_name">'$ACTIVITY_NAME'</string></resources>' > res/values/strings.xml
                        
echo ----------------Building ant files----------------                                                                                                                            
echo '<?xml version="1.0" encoding="UTF-8"?><project name="'$PROJECT_NAME'" default="QC Hybrid Application"><loadproperties srcFile="local.properties" /><property file="ant.properties" /><loadproperties srcFile="project.properties" /><!-- version-tag: '$ANDROID_VERSION' --><import file="'$androidSDK'/tools/ant/build.xml" /></project>' > build.xml  
echo 'target=Google Inc.:Google APIs:'$ANDROID_VERSION > project.properties
exit 0
                                                    
                    