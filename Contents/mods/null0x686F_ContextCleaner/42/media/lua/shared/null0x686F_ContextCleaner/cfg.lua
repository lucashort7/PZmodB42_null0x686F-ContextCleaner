local cfg = {
  enabled = true,
  current_preset = "default",
  active_hide_map = {},
  active_fold_map = {},
  hide_patterns = {},
  fold_patterns = {},
  LOG_LEVEL = (isDebugEnabled and isDebugEnabled()) and "debug" or "info"
}

return cfg
