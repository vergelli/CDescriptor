CDescriptor = CDescriptor or {}

CDescriptor.Constants = {
  ADDON_NAME    = "CDescriptor",
  VERSION       = "0.1.0",
  SLASH_COMMAND = "/cdescriptor",
  DEBUG         = true,

  -- Control names as defined in CDescriptor.xml
  CONTROLS = {
    WINDOW          = "CDescriptorWindow",
    OUTPUT_BOX      = "CDescriptorOutputBox",
    STATUS_LABEL    = "CDescriptorWindowStatusLabel",
    GENERATE_BUTTON = "CDescriptorWindowGenerateButton",
    COPY_BUTTON     = "CDescriptorWindowCopyButton",
  },

  -- UI strings
  UI = {
    GENERATE_BUTTON  = "Generate",
    COPY_BUTTON      = "Copy",
    STATUS_IDLE      = "",
    STATUS_EXTRACT   = "Extracting...",
    STATUS_DONE      = "Done.",
    STATUS_ERROR     = "Error: ",
  },

  -- Saved variables keys
  SAVED_VARS = {
    WINDOW_X = "window_x",
    WINDOW_Y = "window_y",
  },
}
