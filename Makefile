.POSIX:

ECHO	:=	@echo
QUIET	:=	@

all: tests

.PHONY: environment
environment:
	$(QUIET) mkdir -p build

.PHONY: tests
tests: checksum

.PHONY: checksum
checksum: assemble
	$(ECHO) '	SUM'
	$(QUIET) scripts/checksum

.PHONY: assemble
assemble: environment
	$(ECHO) '	ASM'
	$(QUIET) zcc +z80 -subtype=none -o build/v101.bin V1.01_ROM_disassembly_C000.asm

.PHONY: clean
clean:
	$(ECHO) '	RM'
	$(QUIET) rm -rf build

