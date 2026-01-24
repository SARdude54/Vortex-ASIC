INC_DIR := ./include

# Source discovery

RTL_SRCS := $(shell find rtl \( -path 'rtl/fpu' -o -path 'rtl/fpu/*' \) -prune -false -o \
                \( -name '*.sv' -o -name '*.v' \) -print)

# SystemVerilog header include directories (*.svh) + RTL dirs for `include lookups
INCLUDE_DIRS := $(sort $(dir $(shell find . -name '*.svh')))
RTL_DIRS     := $(sort $(dir $(RTL_SRCS)))

# Include both Include and RTL directories for linting/sim
LINT_INCLUDES := $(foreach dir, $(INCLUDE_DIRS) $(RTL_DIRS), -I$(realpath $(dir))) -I$(PDKPATH)

TEST_DIR     := ./tests
TEST_SUBDIRS := $(shell cd $(TEST_DIR) && ls -d */ | grep -v "__pycache__" )
TESTS        := $(TEST_SUBDIRS:/=)

# Disable FPU: remove F/D ISA + force FPU resources off
NOFPU_DEFS := -DEXT_F_DISABLE -DEXT_D_DISABLE -DNUM_FPU_LANES=0 -DNUM_FPU_BLOCKS=0

# Suppress warnings
VERILATOR_QUIET_WARN := -Wno-fatal \
  -Wno-REDEFMACRO -Wno-MULTITOP -Wno-WIDTHTRUNC -Wno-ASCRANGE -Wno-UNOPTFLAT


# Main Linter and Simulator is Verilator
LINTER    := verilator
SIMULATOR := verilator
SIMULATOR_ARGS := --binary --timing --trace --trace-structs \
	--assert --timescale 1ns -sv $(NOFPU_DEFS) $(VERILATOR_QUIET_WARN)


SIMULATOR_BINARY := ./obj_dir/V*

# Compile packages first
PKG_SRCS  := rtl/VX_gpu_pkg.sv
RTL_SRCS_NOPKG := $(filter-out $(PKG_SRCS),$(RTL_SRCS))
ABS_RTL_SRCS := $(realpath $(PKG_SRCS) $(RTL_SRCS_NOPKG))
SIMULATOR_SRCS := $(PKG_SRCS) $(RTL_SRCS_NOPKG) *.sv

# Optional use of Icarus
ifdef ICARUS
SIMULATOR := iverilog
SIMULATOR_ARGS := -g2012 $(NOFPU_DEFS)
SIMULATOR_BINARY := a.out
SIMULATOR_SRCS := $(PKG_SRCS) $(RTL_SRCS_NOPKG) *.sv
SIM_TOP := `$(shell pwd)/scripts/top.sh -s`
endif

# Gate Level Verification
ifdef GL
SIMULATOR := iverilog
LINT_INCLUDES := -I$(PDKPATH) -I$(realpath gl)
SIMULATOR_ARGS := -g2012 -DFUNCTIONAL -DUSE_POWER_PINS
SIMULATOR_BINARY := a.out
SIMULATOR_SRCS := $(realpath gl)/* *.sv
endif

LINT_OPTS += --lint-only --timing -sv $(LINT_INCLUDES) $(NOFPU_DEFS) $(VERILATOR_QUIET_WARN)

# Text formatting for tests
BOLD  = `tput bold`
GREEN = `tput setaf 2`
ORANG = `tput setaf 214`
RED   = `tput setaf 1`
RESET = `tput sgr0`

TEST_GREEN  := $(shell tput setaf 2)
TEST_ORANGE := $(shell tput setaf 214)
TEST_RED    := $(shell tput setaf 1)
TEST_RESET  := $(shell tput sgr0)

all: lint_all tests

lint: lint_all

.PHONY: lint_all
lint_all:
	@printf "\n$(GREEN)$(BOLD) ----- Linting All Modules ----- $(RESET)\n"
	@for src in $(RTL_SRCS); do \
		top_module=$$(basename $$src .sv); \
		top_module=$$(basename $$top_module .v); \
		printf "Linting $$src . . . "; \
		if $(LINTER) $(LINT_OPTS) --top-module $$top_module $$src > /dev/null 2>&1; then \
			printf "$(GREEN)PASSED$(RESET)\n"; \
		else \
			printf "$(RED)FAILED$(RESET)\n"; \
			$(LINTER) $(LINT_OPTS) --top-module $$top_module $$src; \
		fi; \
	done

.PHONY: lint_top
lint_top:
	@printf "\n$(GREEN)$(BOLD) ----- Linting $(TOP_MODULE) ----- $(RESET)\n"
	@printf "Linting Top Level Module: $(TOP_FILE)\n";
	$(LINTER) $(LINT_OPTS) --top-module $(TOP_MODULE) $(TOP_FILE)

tests: $(TESTS)

tests/%: FORCE
	make -s $(subst /,, $(basename $*))

.PHONY: itest_%
itest_%:
	@ICARUS=1 $(MAKE) $*

itests:
	@ICARUS=1 make tests

gl_tests:
	@mkdir -p gl
	@cp runs/recent/final/pnl/* gl/
	@cat scripts/gatelevel.vh gl/*.v > gl/temp
	@mv -f gl/temp gl/*.v
	@rm -f gl/temp
	@GL=1 make tests

.PHONY: $(TESTS)
$(TESTS):
	@printf "\n$(GREEN)$(BOLD) ----- Running Test: $@ ----- $(RESET)\n"
	@printf "\n$(BOLD) Building with $(SIMULATOR)... $(RESET)\n"

# Build With Simulator
	@cd $(TEST_DIR)/$@; \
		$(SIMULATOR) $(SIMULATOR_ARGS) $(ABS_RTL_SRCS) *.sv $(LINT_INCLUDES) $(SIM_TOP) > build.log

	@printf "\n$(BOLD) Running... $(RESET)\n"

# Run Binary and Check for Error in Result
	@if cd $(TEST_DIR)/$@; \
		./$(SIMULATOR_BINARY) > results.log \
		&& !( cat results.log | grep -qi error ); \
		then \
			printf "$(GREEN)PASSED $@$(RESET)\n"; \
		else \
			printf "$(RED)FAILED $@$(RESET)\n"; \
			cat results.log; \
		fi;

COCOTEST_DIR = ./cocotests
COCOTEST_SUBDIRS = $(shell cd $(COCOTEST_DIR) && ls -d */ | grep -v "__pycache__" )
COCOTESTS = $(COCOTEST_SUBDIRS:/=)

.PHONY: cocotests
cocotests:
	@$(foreach test,  $(COCOTESTS), make -sC $(COCOTEST_DIR)/$(test);)

OPENLANE_CONF ?= config.*
openlane:
	@`which openlane` --flow Classic $(OPENLANE_CONF)
	@cd runs && rm -f recent && ln -sf `ls | tail -n 1` recent

%.json %.yaml: FORCE
	@echo $@
	OPENLANE_CONF=$@ make openlane

FORCE: ;

openroad:
	scripts/openroad_launch.sh | openroad

.PHONY: clean
clean:
	rm -f `find tests -iname "*.vcd"`
	rm -f `find tests -iname "a.out"`
	rm -f `find tests -iname "*.log"`
	rm -rf `find tests -iname "obj_dir"`

.PHONY: VERILOG_SOURCES
VERILOG_SOURCES:
	@echo $(realpath $(RTL_SRCS))
