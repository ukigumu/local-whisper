SWIFT ?= swift
CONFIG ?= release
APP_PROJECT = LocalWhisper.xcodeproj
APP_SCHEME = LocalWhisper
APP_DERIVED = build
APP_BUNDLE = $(APP_DERIVED)/Build/Products/Debug/LocalWhisper.app

.PHONY: build run test clean help open app run-app

help:
	@echo "local-whisper"
	@echo ""
	@echo "Targets:"
	@echo "  make build              Build the CLI (CONFIG=release by default)"
	@echo "  make run FILE=talk.mp3  Transcribe a local audio or video file"
	@echo "  make test               Run portable unit tests"
	@echo "  make open               Open LocalWhisper.xcodeproj (macOS / Xcode)"
	@echo "  make app                Build the Mac app with xcodebuild"
	@echo "  make run-app            Build and launch the Mac app"
	@echo "  make clean              Remove .build and local Xcode derived data"
	@echo "  make help               Show this help"
	@echo ""
	@echo "Examples:"
	@echo "  make build"
	@echo "  make run FILE=talk.mp3"
	@echo "  make run FILE=clip.mp4 ARGS='--model tiny --verbose'"
	@echo "  make open"
	@echo "  make test"
	@echo ""
	@echo "macOS is required for a working transcription build."
	@echo "The SwiftUI app needs Xcode 16+ on a Mac. Linux can typecheck LocalWhisperCore via make test if Swift is installed."

build:
	$(SWIFT) build -c $(CONFIG) --product local-whisper

run:
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make run FILE=talk.mp3 [ARGS='--verbose']"; \
		exit 1; \
	fi
	$(SWIFT) run -c $(CONFIG) local-whisper $(FILE) $(ARGS)

test:
	$(SWIFT) test

open:
	@if [ ! -d "$(APP_PROJECT)" ]; then \
		echo "Missing $(APP_PROJECT)"; \
		exit 1; \
	fi
	@if command -v open >/dev/null 2>&1; then \
		open $(APP_PROJECT); \
	else \
		echo "open is not available. On a Mac, run: open LocalWhisper.xcodeproj"; \
		exit 1; \
	fi

app:
	@if ! command -v xcodebuild >/dev/null 2>&1; then \
		echo "xcodebuild is not on this machine."; \
		echo "The Mac app is Mac-ready. On macOS 14+ with Xcode 16+:"; \
		echo "  open LocalWhisper.xcodeproj"; \
		echo "  make app"; \
		echo "Linux can still run: make test"; \
		exit 1; \
	fi
	xcodebuild \
		-project $(APP_PROJECT) \
		-scheme $(APP_SCHEME) \
		-configuration Debug \
		-derivedDataPath $(APP_DERIVED) \
		CODE_SIGN_IDENTITY="-" \
		AD_HOC_CODE_SIGNING_ALLOWED=YES \
		build

run-app: app
	open $(APP_BUNDLE)

clean:
	$(SWIFT) package clean
	rm -rf .build $(APP_DERIVED)
