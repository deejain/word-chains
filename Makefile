PROJECT_ROOT:=$(CURDIR)
OUTPUT_DIR:=$(PROJECT_ROOT)/output
DATA_DIR:=$(PROJECT_ROOT)/data
GENERATED_OUTPUT_DIR:=$(OUTPUT_DIR)/generated
GENERATED_READABLE_OUTPUT_DIR:=$(OUTPUT_DIR)/generated-readable
LUA_SOURCE_PATH:=$(PROJECT_ROOT)/src/lua
LUA_OUTPUT_DIR:=$(OUTPUT_DIR)/lua
LUA_GENERATED_DIR:=$(GENERATED_OUTPUT_DIR)/lua
LUAJIT_HOST:=luajit
PRECOMPILE_TOOLS_PATH:=$(PROJECT_ROOT)/tools/precompile
PRECOMPILE_TOOLS_PACKAGE_PATH:=$(LUA_SOURCE_PATH)/?.lua;$(PRECOMPILE_TOOLS_PATH)/?.lua;
ADJACENCY_LIST_GENERATOR:=$(PRECOMPILE_TOOLS_PATH)/adjacencylist_generator.lua
LUAJIT_ARGS=-bg


DATA_FILES:=$(shell find $(DATA_DIR) -type f -name "*.txt")
LUA_SOURCE_FILES:=$(shell find $(LUA_SOURCE_PATH) -type f -name "*.lua")

GENERATED_LUA_FILES:=$(patsubst $(DATA_DIR)/%.txt, $(GENERATED_OUTPUT_DIR)/%.lua, $(DATA_FILES))
LUA_OUTPUT_FILES:=$(patsubst $(LUA_SOURCE_PATH)/%.lua, $(LUA_OUTPUT_DIR)/%.lua, $(LUA_SOURCE_FILES)) \
				  $(patsubst $(GENERATED_OUTPUT_DIR)/%.lua, $(LUA_OUTPUT_DIR)/%.lua, $(GENERATED_LUA_FILES))

# Uncomment the target below to print all variables.
# .PHONY: printvars
# printvars:
# 	@$(foreach V,$(sort $(.VARIABLES)),$(if $(filter-out environment% default automatic,$(origin $V)),$(warning $V=$($V) ($(value $V)))))

# Note, for now, we're not including the build target because the LuaJIT complains about compiling words.lua, since it has more than
# 65,536 constants (strings).  In the the future, we may just want to compile the source files and use the raw Lua adjacency list files.
all: prebuild

prebuild: $(GENERATED_LUA_FILES)
build: $(LUA_OUTPUT_FILES)

$(GENERATED_OUTPUT_DIR)/%.lua: $(DATA_DIR)/%.txt $(ADJACENCY_LIST_GENERATOR) $(LUA_SOURCE_FILES)
	@echo "Processing: $<"
	@mkdir -p `dirname "$@"` $(GENERATED_READABLE_OUTPUT_DIR)
	@$(LUAJIT_HOST) $(word 2,$^) $(word 2,$^) "$(PRECOMPILE_TOOLS_PACKAGE_PATH)" $< $@ $(GENERATED_READABLE_OUTPUT_DIR)/`basename $@`
	@echo "Generated:  $@"
	@echo "Generated:  $(GENERATED_READABLE_OUTPUT_DIR)/`basename $@`"

$(LUA_OUTPUT_DIR)/%.lua: $(GENERATED_OUTPUT_DIR)/%.lua
	@echo "Precompile: $<"
	@mkdir -p `dirname "$@"`
	@$(LUAJIT_HOST) $(LUAJIT_ARGS) $< $@
	@echo "Generated:  $@"

$(LUA_OUTPUT_DIR)/%.lua: $(LUA_SOURCE_PATH)/%.lua
	@echo "Precompile: $<"
	@mkdir -p `dirname "$@"`
	@$(LUAJIT_HOST) $(LUAJIT_ARGS) $< $@
	@echo "Generated:  $@"

clean:
	@rm -rf $(OUTPUT_DIR)
