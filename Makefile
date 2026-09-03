SWIFT ?= swift
CONFIG ?= release

.PHONY: build run test clean help

help:
	@echo "local-whisper"
	@echo ""
	@echo "Targets:"
	@echo "  make build              Build the CLI (CONFIG=release by default)"
	@echo "  make run FILE=talk.mp3  Transcribe a local audio or video file"
	@echo "  make test               Run portable unit tests"
	@echo "  make clean              Remove .build"
	@echo "  make help               Show this help"
	@echo ""
	@echo "Examples:"
	@echo "  make build"
	@echo "  make run FILE=talk.mp3"
	@echo "  make run FILE=clip.mp4 ARGS='--model tiny --verbose'"
	@echo "  make test"
	@echo ""
	@echo "macOS is required for a working transcription build."
	@echo "Linux can typecheck LocalWhisperCore via make test if Swift is installed."

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

clean:
	$(SWIFT) package clean
	rm -rf .build
