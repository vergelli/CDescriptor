-- Manages the prompt configuration window (Feature 4 + 5).
CDescriptor = CDescriptor or {}
CDescriptor.PromptUI = {}

local M = CDescriptor.PromptUI
local C
local Controls = {}

-- ── Content type resolution ────────────────────────────────────────────────

local CONTENT_TYPES = {
  ["PvE:Solo"]                        = "PvE solo content.",
  ["PvE:Dungeons"]                    = "PvE group dungeon content.",
  ["PvE:Dungeons:Normal"]             = "PvE group dungeon content, normal difficulty.",
  ["PvE:Dungeons:Veteran"]            = "PvE group dungeon content, veteran difficulty.",
  ["PvE:Dungeons:Veteran Hard Mode"]  = "PvE group dungeon content, veteran hard mode difficulty.",
  ["PvE:Trials"]                      = "PvE Trial content (12-player).",
  ["PvE:Trials:Normal"]               = "PvE Trial content (12-player), normal difficulty.",
  ["PvE:Trials:Veteran"]              = "PvE Trial content (12-player), veteran difficulty.",
  ["PvE:Trials:Veteran Hard Mode"]    = "PvE Trial content (12-player), veteran hard mode — hardest PvE content in the game.",
  ["PvP:Cyrodiil"]                    = "PvP open world (Cyrodiil).",
  ["PvP:Imperial City"]               = "PvP Imperial City.",
  ["PvP:Battlegrounds"]               = "PvP instanced (Battlegrounds).",
}

local ROLE_TYPES = {
  [""]        = "Full analysis: damage, survivability, and support.",
  ["DPS"]     = "Prioritize maximizing damage output.",
  ["Tank"]    = "Prioritize maximizing survivability and damage mitigation.",
  ["Healer"]  = "Prioritize maximizing support and healing output.",
  ["Hybrid"]  = "Hybrid role: balance between damage and survivability or support.",
}

local SUBCATS = {
  PvE = { "", "Solo", "Dungeons", "Trials" },
  PvP = { "", "Cyrodiil", "Imperial City", "Battlegrounds" },
}
local DIFFS_FOR = { Dungeons = true, Trials = true }
local DIFFS = { "", "Normal", "Veteran", "Veteran Hard Mode" }

-- ── Helpers ────────────────────────────────────────────────────────────────

local function sv(key)       return CDescriptor.Settings.get(key)   end
local function sv_set(k, v)  CDescriptor.Settings.set(k, v)         end

local function combo(ctrl)   return ctrl.m_comboBox                  end

local function get_content_type_str()
  local cat  = sv(C.SAVED_VARS.PROMPT_CAT)  or ""
  local sub  = sv(C.SAVED_VARS.PROMPT_SUB)  or ""
  local diff = sv(C.SAVED_VARS.PROMPT_DIFF) or ""
  if cat == "" then return "Infer from the build data provided." end
  local key = diff ~= "" and (cat..":"..sub..":"..diff)
           or sub  ~= "" and (cat..":"..sub)
           or nil
  if not key then return "Infer from the build data provided." end
  return CONTENT_TYPES[key] or "Infer from the build data provided."
end

local function get_role_str()
  local role = sv(C.SAVED_VARS.PROMPT_ROLE) or ""
  return ROLE_TYPES[role] or ROLE_TYPES[""]
end

-- ── ComboBox population ────────────────────────────────────────────────────

local sub_combo_cb -- forward declaration for use in populate_sub
local diff_combo_cb

local function populate_sub(cat)
  local sub_combo = combo(Controls.content_sub)
  sub_combo:ClearItems()
  local options = SUBCATS[cat]
  if not options then
    Controls.content_sub:SetHidden(true)
    Controls.content_diff:SetHidden(true)
    return
  end
  Controls.content_sub:SetHidden(false)
  for _, name in ipairs(options) do
    sub_combo:AddItem(sub_combo:CreateItemEntry(name == "" and "── select ──" or name,
      function() sub_combo_cb(name) end))
  end
  -- Restore saved selection
  local saved = sv(C.SAVED_VARS.PROMPT_SUB) or ""
  local display = saved == "" and "── select ──" or saved
  Controls.content_sub:GetNamedChild("SelectedItemText"):SetText(display)
  -- Show/hide diff based on saved sub
  local show_diff = DIFFS_FOR[saved] == true
  Controls.content_diff:SetHidden(not show_diff)
end

local function populate_diff()
  local diff_combo = combo(Controls.content_diff)
  diff_combo:ClearItems()
  for _, name in ipairs(DIFFS) do
    diff_combo:AddItem(diff_combo:CreateItemEntry(name == "" and "── select ──" or name,
      function() diff_combo_cb(name) end))
  end
  -- Restore saved selection
  local saved = sv(C.SAVED_VARS.PROMPT_DIFF) or ""
  local display = saved == "" and "── select ──" or saved
  Controls.content_diff:GetNamedChild("SelectedItemText"):SetText(display)
end

local function update_warning()
  local custom = sv(C.SAVED_VARS.PROMPT_CUSTOM)
  if custom and custom ~= "" then
    local missing = CDescriptor.Prompt.missing_placeholders(custom)
    if #missing > 0 then
      Controls.warn_label:SetText("Some dynamic fields not in your custom prompt: " .. table.concat(missing, ", "))
    else
      Controls.warn_label:SetText("")
    end
  else
    Controls.warn_label:SetText("")
  end
end

-- ── Callbacks ──────────────────────────────────────────────────────────────

function sub_combo_cb(name)
  sv_set(C.SAVED_VARS.PROMPT_SUB,  name)
  sv_set(C.SAVED_VARS.PROMPT_DIFF, "")  -- reset diff on sub change
  local show_diff = DIFFS_FOR[name] == true
  Controls.content_diff:SetHidden(not show_diff)
  if show_diff then populate_diff() end
end

function diff_combo_cb(name)
  sv_set(C.SAVED_VARS.PROMPT_DIFF, name)
end

local editing_manually = false

function M.on_patch_changed()
  local text = Controls.patch_input:GetText()
  sv_set(C.SAVED_VARS.PROMPT_PATCH, text)
end

function M.on_prompt_text_changed()
  local text = Controls.prompt_text:GetText()
  sv_set(C.SAVED_VARS.PROMPT_CUSTOM, text)
  update_warning()
end

function M.toggle_edit()
  editing_manually = not editing_manually
  Controls.text_bg:SetHidden(not editing_manually)
  Controls.edit_btn:SetText(editing_manually and "Hide prompt text" or "Edit manually")
  if editing_manually then
    local custom = sv(C.SAVED_VARS.PROMPT_CUSTOM)
    Controls.prompt_text:SetText(custom and custom ~= "" and custom or CDescriptor.Prompt.DEFAULT_PROMPT)
  end
end

function M.reset_prompt()
  sv_set(C.SAVED_VARS.PROMPT_CUSTOM, nil)
  if editing_manually then
    Controls.prompt_text:SetText(CDescriptor.Prompt.DEFAULT_PROMPT)
  end
  Controls.warn_label:SetText("")
end

function M.close()
  Controls.window:SetHidden(true)
  -- Uncheck "Include prompt" in main window
  local SV = C.SAVED_VARS
  sv_set(SV.INCLUDE_PROMPT, false)
  local check = _G[C.CONTROLS.CHECK_PROMPT]
  if check then ZO_CheckButton_SetCheckState(check, false) end
end

function M.on_move_stop()
  local x, y = Controls.window:GetScreenRect()
  sv_set(C.SAVED_VARS.PROMPT_WIN_X, x)
  sv_set(C.SAVED_VARS.PROMPT_WIN_Y, y)
end

-- ── Init ──────────────────────────────────────────────────────────────────

function M.init()
  C = CDescriptor.Constants
  local names = C.CONTROLS

  Controls.window       = _G[names.PROMPT_WINDOW]
  Controls.patch_input  = _G[names.PROMPT_PATCH]
  Controls.content_cat  = _G[names.PROMPT_CONTENT_CAT]
  Controls.content_sub  = _G[names.PROMPT_CONTENT_SUB]
  Controls.content_diff = _G[names.PROMPT_CONTENT_DIFF]
  Controls.role         = _G[names.PROMPT_ROLE]
  Controls.warn_label   = _G[names.PROMPT_WARN_LABEL]
  Controls.edit_btn     = _G[names.PROMPT_WINDOW .. "EditBtn"]
  Controls.reset_btn    = _G[names.PROMPT_WINDOW .. "ResetBtn"]
  Controls.text_bg      = _G[names.PROMPT_WINDOW .. "TextBg"]
  Controls.prompt_text  = _G[names.PROMPT_TEXT]

  local SV = C.SAVED_VARS

  -- Button labels
  Controls.edit_btn:SetText("Edit manually")
  Controls.reset_btn:SetText("Reset to default")

  -- Restore patch input
  Controls.patch_input:SetText(sv(SV.PROMPT_PATCH) or "")

  -- Populate category combo
  local cat_combo = combo(Controls.content_cat)
  cat_combo:SetSortsItems(false)
  cat_combo:AddItem(cat_combo:CreateItemEntry("── select ──", function()
    sv_set(SV.PROMPT_CAT, "")
    sv_set(SV.PROMPT_SUB, "")
    sv_set(SV.PROMPT_DIFF, "")
    Controls.content_sub:SetHidden(true)
    Controls.content_diff:SetHidden(true)
  end))
  cat_combo:AddItem(cat_combo:CreateItemEntry("PvE", function()
    sv_set(SV.PROMPT_CAT, "PvE")
    sv_set(SV.PROMPT_SUB, "")
    sv_set(SV.PROMPT_DIFF, "")
    populate_sub("PvE")
  end))
  cat_combo:AddItem(cat_combo:CreateItemEntry("PvP", function()
    sv_set(SV.PROMPT_CAT, "PvP")
    sv_set(SV.PROMPT_SUB, "")
    sv_set(SV.PROMPT_DIFF, "")
    populate_sub("PvP")
  end))

  -- Restore category selection display
  local saved_cat = sv(SV.PROMPT_CAT) or ""
  local cat_display = saved_cat == "" and "── select ──" or saved_cat
  Controls.content_cat:GetNamedChild("SelectedItemText"):SetText(cat_display)

  -- Populate sub/diff based on saved category
  if saved_cat ~= "" then
    populate_sub(saved_cat)
    if DIFFS_FOR[sv(SV.PROMPT_SUB) or ""] then
      populate_diff()
    end
  else
    Controls.content_sub:SetHidden(true)
    Controls.content_diff:SetHidden(true)
  end

  -- Populate role combo
  local role_combo = combo(Controls.role)
  role_combo:SetSortsItems(false)
  local roles = { "", "DPS", "Tank", "Healer", "Hybrid" }
  local role_labels = { "── full analysis ──", "DPS", "Tank", "Healer", "Hybrid" }
  for i, key in ipairs(roles) do
    local label = role_labels[i]
    role_combo:AddItem(role_combo:CreateItemEntry(label, function()
      sv_set(SV.PROMPT_ROLE, key)
    end))
  end
  local saved_role = sv(SV.PROMPT_ROLE) or ""
  local role_display = saved_role == "" and "── full analysis ──" or saved_role
  Controls.role:GetNamedChild("SelectedItemText"):SetText(role_display)

  -- Restore window position
  local x = sv(SV.PROMPT_WIN_X)
  local y = sv(SV.PROMPT_WIN_Y)
  if x and y then
    Controls.window:ClearAnchors()
    Controls.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
  end

  update_warning()
end

-- ── Show/hide ──────────────────────────────────────────────────────────────

function M.show()
  Controls.window:SetHidden(false)
end

function M.hide()
  Controls.window:SetHidden(true)
end

-- ── Build settings for prompt engine ──────────────────────────────────────

function M.build_prompt_settings()
  local SV = C.SAVED_VARS
  return {
    custom_prompt  = sv(SV.PROMPT_CUSTOM),
    patch          = sv(SV.PROMPT_PATCH) or "",
    content_type   = get_content_type_str(),
    analysis_focus = get_role_str(),
  }
end
