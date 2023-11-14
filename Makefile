# Stuff to edit is here

# ROM Name
ROM_NAME    = engine
# Header stuff
GAME_TITLE  = ENGINE
GAME_CODE   = TEST
LICENSEE    = "01"
ROM_NAME    = engine
VERSION     = 0
MBC_VALUE   = 0x11
RAM_SIZE    = 0
IS_JPN      = false
CGB_ONLY    = false
CGB_SUPPORT = true
SGB_SUPPORT = false

# Don't edit below unless you know what you're doing

ifeq ($(CGB_ONLY), true)
ROM_TYPE = gbc
else ifeq ($(CGB_SUPPORT), true)
ROM_TYPE = gbc
else ifeq ($(SGB_SUPPORT), true)
ROM_TYPE = sgb
else
ROM_TYPE = gb
endif

game_obj := \
home.o \
ram.o

RGBDS ?=
RGBASM  ?= $(RGBDS)rgbasm
RGBFIX  ?= $(RGBDS)rgbfix
RGBGFX  ?= $(RGBDS)rgbgfx
RGBLINK ?= $(RGBDS)rgblink

.PHONY: all clean tidy

all: game
game: $(ROM_NAME).$(ROM_TYPE)

clean: tidy
	find gfx \( -name "*.[12]bpp" \) -delete

tidy:
	rm -f $(ROM_NAME).gb $(ROM_NAME).sgb $(ROM_NAME).gbc $(game_obj) $(ROM_NAME).map $(ROM_NAME).sym
	$(MAKE) clean -C tools/

tools:
	$(MAKE) -C tools/

fix_opt = -v -t $(GAME_TITLE) -i $(GAME_CODE) -n $(VERSION) -k $(LICENSEE) -l 0x33 -m $(MBC_VALUE) -r $(RAM_SIZE) -p 0

ifeq ($(IS_JPN),true)
	asm_def := -D IS_JPN=1
else
	fix_opt := $(fix_opt) -j
	asm_def := -D IS_JPN=0
endif

ifeq ($(CGB_SUPPORT),true)
	asm_def := $(asm_def) -D CGB_SUPPORT=1
	ifeq ($(CGB_ONLY),true)
		asm_def := $(asm_def) -D CGB_ONLY=1
		fix_opt := $(fix_opt) -C
	else
		asm_def := $(asm_def) -D CGB_ONLY=0
		fix_opt := $(fix_opt) -c
	endif
else
	asm_def := $(asm_def) -D CGB_SUPPORT=0
endif

ifeq ($(SGB_SUPPORT),true)
	asm_def := $(asm_def) -D SGB_SUPPORT=1
	fix_opt := $(fix_opt) -s
else
	asm_def := $(asm_def) -D SGB_SUPPORT=0
endif

RGBASMFLAGS = -hL -Weverything $(asm_def)

define DEP
$1: $2 $$(shell tools/scan_includes $2)
	$$(RGBASM) $$(RGBASMFLAGS) -o $$@ $$<
endef

ifeq (,$(filter clean tidy tools,$(MAKECMDGOALS)))

$(info $(shell $(MAKE) -C tools))

$(foreach obj, $(game_obj), $(eval $(call DEP,$(obj),$(obj:.o=.asm))))

endif

$(ROM_NAME).$(ROM_TYPE): $(game_obj) layout.link
	$(RGBLINK) -n $(ROM_NAME).sym -m $(ROM_NAME).map -l layout.link -o $@ $(filter %.o,$^)
	$(RGBFIX) $(fix_opt) $@

%.2bpp: %.png
	$(RGBGFX) $(rgbgfx) -o $@ $<

%.1bpp: %.png
	$(RGBGFX) $(rgbgfx) -d1 -o $@ $<

%.gbcpal: %.png
	$(RGBGFX) -p $@ $<
