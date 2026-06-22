-- Bemol workspace folder integration for jdtls in Brazil workspaces.
-- Adds .bemol/ws_root_folders to the LSP workspace on attach.
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("bemol-workspace-folders", { clear = true }),
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if not client or client.name ~= "jdtls" then
			return
		end

		local bemol_dir = vim.fs.find({ ".bemol" }, { upward = true, type = "directory" })[1]
		if not bemol_dir then
			return
		end

		local file = io.open(bemol_dir .. "/ws_root_folders", "r")
		if not file then
			return
		end

		local existing = vim.lsp.buf.list_workspace_folders()
		for line in file:lines() do
			if not vim.tbl_contains(existing, line) then
				vim.lsp.buf.add_workspace_folder(line)
			end
		end
		file:close()
	end,
})

return {}
