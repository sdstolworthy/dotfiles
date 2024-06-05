for _, plugin in ipairs({ './dap_config', './filetree_config', './keymaps_config', './formatter_config', './lsp_config', './startup_config', './telescope_config', './terminal_config' }) do
  require(plugin)
end
