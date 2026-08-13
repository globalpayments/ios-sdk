CONFIG_PROJECT := Example/Pods/Pods.xcodeproj
CONFIG_WORKSPACE := Example/GlobalPayments-iOS-SDK.xcworkspace
CONFIG_SCHEME := GlobalPayments-iOS-SDK
CONFIG_FRAMEWORK := GlobalPayments_iOS_SDK.framework
CONFIG_XCFRAMEWORK := Deliverables/GlobalPayments-iOS-SDK.xcframework
CONFIG_SDK := iphonesimulator
CONFIG_DESTINATION := 'platform=iOS Simulator,name=iPhone 16'

# Needed in case zsh is default shell
SHELL := /bin/bash

.DEFAULT_GOAL := test

define run_scheme_command
	xcodebuild $(2) \
		-workspace ${CONFIG_WORKSPACE} \
		-scheme $(1) \
		-sdk ${CONFIG_SDK} \
		-destination ${CONFIG_DESTINATION}
endef

.PHONY: clean pods test xcode build-xcframework

pods:
	cd Example && pod install

build-xcframework: pods
	rm -rf tmp ${CONFIG_XCFRAMEWORK}
	xcodebuild archive \
		-project ${CONFIG_PROJECT} \
		-scheme ${CONFIG_SCHEME} \
		-configuration Release \
		-archivePath tmp/xcf/ios.xcarchive \
		-derivedDataPath tmp/iphoneos \
		-sdk iphoneos \
		SKIP_INSTALL=NO \
		BUILD_LIBRARY_FOR_DISTRIBUTION=YES
	xcodebuild archive \
		-project ${CONFIG_PROJECT} \
		-scheme ${CONFIG_SCHEME} \
		-configuration Release \
		-archivePath tmp/xcf/iossimulator.xcarchive \
		-derivedDataPath tmp/iphonesimulator \
		-sdk iphonesimulator \
		SKIP_INSTALL=NO \
		BUILD_LIBRARY_FOR_DISTRIBUTION=YES
	mkdir -p Deliverables
	xcodebuild -create-xcframework \
		-framework tmp/xcf/ios.xcarchive/Products/Library/Frameworks/${CONFIG_FRAMEWORK} \
		-framework tmp/xcf/iossimulator.xcarchive/Products/Library/Frameworks/${CONFIG_FRAMEWORK} \
		-output ${CONFIG_XCFRAMEWORK}
	rm -rf tmp

clean:
	rm -rf tmp Deliverables Build Carthage

test: pods
	$(call run_scheme_command, GlobalPayments-iOS-SDK-Example, test)

xcode:
	open ${CONFIG_WORKSPACE}
