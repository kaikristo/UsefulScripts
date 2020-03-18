if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )
set APP_NAME=DTD

set UNITY17=2017.4.37f1
set UNITY18=2018.4.18f1
set UNITY19=2019.1.7f1

set UNITY="C:\Program Files\Unity\Hub\Editor\%UNITY17%\Editor\Unity.exe"
set APP_PATH=%cd%
set OUTPATH="out\Windows32\%APP_NAME%.exe"
echo fuck_compatibiliy

echo Build native libraries from windows

echo ANDROID
cd sdk\extensions\android\ & call .\gradlew clean build
echo complete
cd "%APP_PATH%"
@echo off
echo 
::Nuget restore sdk/extensions/Metro/Metro.sln

echo METRO
MSBuild sdk/extensions/Metro/Metro.csproj /p:Configuration=Release /t:Clean;Build
MSBuild sdk/extensions/MetroBackgroundTask/MetroBackgroundTask.csproj /p:Configuration=Release /p:DefineConstants=\"BACKGROUND_TASK;\" /t:Clean;Build"
MSBuild sdk/extensions/PlatformsLibrary/DTD_Metro/DTD_Platforms.csproj /p:Configuration=Release /t:Clean;Build"
MSBuild sdk/extensions/PlatformsLibrary/DTD_Metro/DTD_Metro.csproj /p:Configuration=Release /t:Clean;Build"

echo ARCHIVE libraries from windows
set android=sdk\extensions\android\sdk\build\outputs\aar\sdk-release.aar
set metro=sdk\extensions\Metro\bin\Release\Metro.dll
set metro_background=sdk\extensions\MetroBackgroundTask\bin\Release\devtodev.background.winmd
set metro_devtodev=sdk\extensions\PlatformsLibrary\DTD_Metro\bin\Release\Metro\devtodev.dll
copy /y sdk\extensions\PlatformsLibrary\DTD_Metro\bin\Release\Metro\devtodev.dll sdk\sdk\devtodev.dll

MSBuild sdk/sdk/sdk.sln /p:Configuration=Release /t:Clean;Build

set dll_standalone=sdk\sdk\Temp\bin\Release\Standalone\devtodev_cross.dll
set dll_android=sdk\sdk\Temp\bin\Release\Android\devtodev_cross.dll
set dll_ios=sdk\sdk\Temp\bin\Release\ios\devtodev_cross.dll
set dll_metro=sdk\sdk\Temp\bin\Release\metro\devtodev_cross.dll
set dll_webgl=sdk\sdk\Temp\bin\Release\WebGL\devtodev_cross.dll

del sdk\Package\Assets\Plugins\Android\devtodev.aar

copy /y %dll_android% sdk\Package\Assets\Plugins\Android\devtodev_cross.dll
copy /y %android% sdk\Package\Assets\Plugins\Android\devtodev.aar

::for ios build
::copy /y %dll_ios% sdk\Package\Assets\Plugins\iOS\devtodev_cross.dll
::copy /y %ios% sdk\Package\Assets\Plugins\iOS\

copy /y %dll_standalone% sdk\Package\Assets\Plugins\Standalone\devtodev_cross.dll

copy /y %dll_webgl% sdk\Package\Assets\Plugins\WebGL\devtodev_cross.dll

::for mac build
::copy /y %dll_macos% sdk\Package\Assets\Plugins\devtodev_cross.dll

copy /y %dll_metro% sdk\Package\Assets\Plugins\Metro\devtodev_cross.dll

copy /y %metro% sdk\Package\Assets\Plugins\Metro\Metro.dll
copy /y %metro_background% sdk\Package\Assets\Plugins\Metro\devtodev.background.winmd
copy /y %metro_devtodev% sdk\Package\Assets\Plugins\Metro\devtodev.dll

echo create Package
cd sdk\Package
call %UNITY% -gvh_disable -quit -batchmode -projectPath %cd% -exportPackage Assets/devtodev Assets/Resources Assets/Plugins Assets/PlayServicesResolver devtodev.unitypackage -logFile log.txt 
cd %APP_PATH%
set unitypackage=%cd%\devtodev.unitypackage

echo Export Package
call %UNITY% -gvh -quit -batchmode -importPackage %unitypackage% -projectPath %cd%\application -logFile log.txt

echo Build Applications

call %UNITY% -gvh -quit -batchmode -executeMethod BuildCI.PerformWindowsBuild -projectPath %cd%\application -logFile log.txt
                                      
pause
