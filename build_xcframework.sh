#!/bin/sh

set -e -E -u -o pipefail

BUILD_DIR=$(dirname $0)/.build
SOURCES_DIR=$(dirname $0)/ReactiveObjC

TARGET_XCFRAMEWORK=$(dirname $0)/ReactiveObjC.xcframework

mkdir -p $BUILD_DIR

if [ -d $SOURCES_DIR ]; then
    cd $SOURCES_DIR
    git pull -r
    git submodule update --init --recursive --depth 1
else
    git clone --depth 1 https://github.com/ReactiveCocoa/ReactiveObjC $SOURCES_DIR
    cd $SOURCES_DIR
    git submodule update --init --recursive --depth 1
fi

#
# those are for specific archs only
# no need to pick up single archs
#
#xcodebuild archive \
#    -workspace ReactiveObjC.xcworkspace \
#    -scheme ReactiveObjC-iOS \
#    -sdk iphoneos \
#    -arch arm64 \
#    -archivePath $BUILD_DIR/iphoneos.xcarchive \
#    SKIP_INSTALL=NO \
#    BUILD_LIBRARY_FOR_DISTRIBUTION=YES
#
#xcodebuild archive \
#    -workspace ReactiveObjC.xcworkspace \
#    -scheme ReactiveObjC-iOS \
#    -sdk iphonesimulator \
#    -arch arm64 \
#    -archivePath $BUILD_DIR/iphonesimulator_arm64.xcarchive \
#    SKIP_INSTALL=NO \
#    BUILD_LIBRARY_FOR_DISTRIBUTION=YES
#
#xcodebuild archive \
#    -workspace ReactiveObjC.xcworkspace \
#    -scheme ReactiveObjC-iOS \
#    -sdk iphonesimulator \
#    -arch x86_64 \
#    -archivePath $BUILD_DIR/iphonesimulator_x86_64.xcarchive \
#    SKIP_INSTALL=NO \
#    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

#
# those are for all archs (like a fat framework, but without lipo)
#
xcodebuild archive \
    -workspace ReactiveObjC.xcworkspace \
    -scheme ReactiveObjC-iOS \
    -configuration Release \
    -sdk iphoneos \
    -archivePath $BUILD_DIR/iphoneos.xcarchive \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    ONLY_ACTIVE_ARCH=NO

xcodebuild archive \
    -workspace ReactiveObjC.xcworkspace \
    -scheme ReactiveObjC-iOS \
    -configuration Release \
    -sdk iphonesimulator \
    -archivePath $BUILD_DIR/iphonesimulator.xcarchive \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    ONLY_ACTIVE_ARCH=NO

if [ -d $TARGET_XCFRAMEWORK ]; then
    rm -rf $TARGET_XCFRAMEWORK
fi

xcodebuild -create-xcframework \
    -framework $BUILD_DIR/iphoneos.xcarchive/Products/@rpath/ReactiveObjC.framework \
    -framework $BUILD_DIR/iphonesimulator.xcarchive/Products/@rpath/ReactiveObjC.framework \
    -output $TARGET_XCFRAMEWORK
