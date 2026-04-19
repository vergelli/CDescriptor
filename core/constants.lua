CDescriptor = CDescriptor or {}

CDescriptor.Constants = {
  ADDON_NAME    = "CDescriptor",
  VERSION       = "0.1.0",
  SLASH_COMMAND = "/cdescriptor",
  DEBUG         = false,

  -- Control names as defined in CDescriptor.xml
  CONTROLS = {
    WINDOW          = "CDescriptorWindow",
    OUTPUT_BOX      = "CDescriptorOutputBox",
    SCROLLBAR       = "CDescriptorScrollbar",
    STATUS_LABEL    = "CDescriptorWindowStatusLabel",
    GENERATE_BUTTON = "CDescriptorWindowGenerateButton",
    COPY_BUTTON     = "CDescriptorWindowCopyButton",
    CLEAR_BUTTON    = "CDescriptorWindowClearButton",
    CHECK_SETS      = "CDescriptorWindowCheckSets",
    CHECK_STATS     = "CDescriptorWindowCheckStats",
    CHECK_BUFFS     = "CDescriptorWindowCheckBuffs",
  },

  -- UI strings
  UI = {
    GENERATE_BUTTON   = "Generate",
    COPY_BUTTON       = "Select",
    CLEAR_BUTTON      = "Clear",
    STATUS_IDLE       = "",
    STATUS_EXTRACT    = "Extracting...",
    STATUS_DONE       = "Done.",
    STATUS_ERROR      = "Error: ",
    STATUS_COPY       = "Selected — press Ctrl+C to copy",
    CHECK_SETS_LABEL  = "Set descriptions",
    CHECK_STATS_LABEL = "Combat stats",
    CHECK_BUFFS_LABEL = "Active buffs",
  },

  -- Saved variables keys
  SAVED_VARS = {
    WINDOW_X      = "window_x",
    WINDOW_Y      = "window_y",
    WINDOW_W      = "window_w",
    WINDOW_H      = "window_h",
    INCLUDE_SETS  = "include_sets",
    INCLUDE_STATS = "include_stats",
    INCLUDE_BUFFS = "include_buffs",
  },
}
