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
game: $(ROM_NAME).gb

clean: tidy
	find gfx \( -name "*.[12]bpp" \) -delete

tidy:
	rm -f $(ROM_NAME).gb $(game_obj) $(ROM_NAME).map $(ROM_NAME).sym
	$(MAKE) clean -C tools/

tools:
	$(MAKE) -C tools/

RGBASMFLAGS = -L -Weverything

define DEP
$1: $2 $$(shell tools/scan_includes $2)
	$$(RGBASM) $$(RGBASMFLAGS) -o $$@ $$<
endef

ifeq (,$(filter clean tidy tools,$(MAKECMDGOALS)))

$(info $(shell $(MAKE) -C tools))

$(foreach obj, $(game_obj), $(eval $(call DEP,$(obj),$(obj:.o=.asm))))

endif

fix_opt = -v -t $(GAME_TITLE) -i $(GAME_CODE) -n $(VERSION) -k $(LICENSEE) -l 0x33 -m $(MBC_VALUE) -r $(RAM_SIZE) -p 0

ifeq ($(IS_JPN),true)
	# nothing
else
	fix_opt := $(fix_opt) -j
endif

ifeq ($(CGB_SUPPORT),true)
	ifeq ($(CGB_ONLY),true)
		fix_opt := $(fix_opt) -C
	else
		fix_opt := $(fix_opt) -c
	endif
else
	# nothing
endif

ifeq ($(SGB_SUPPORT),true)
	fix_opt := $(fix_opt) -s
else
	# nothing
endif

$(ROM_NAME).gb: $(game_obj) layout.link
	$(RGBLINK) -n $(ROM_NAME).sym -m $(ROM_NAME).map -l layout.link -o $@ $(filter %.o,$^)
	$(RGBFIX) $(fix_opt) $@

%.2bpp: %.png
	$(RGBGFX) $(rgbgfx) -o $@ $<

%.1bpp: %.png
	$(RGBGFX) $(rgbgfx) -d1 -o $@ $<

%.gbcpal: %.png
	$(RGBGFX) -p $@ $<
