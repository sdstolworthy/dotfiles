vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4
vim.opt_local.shiftwidth = 4

local jdtls = require("jdtls")
local jdtls_setup = require("jdtls.setup")

local home = os.getenv("HOME")
local root_dir = jdtls_setup.find_root({ ".git", "build.gradle", "build.gradle.kts", "pom.xml", ".bemol" })
local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
local workspace_dir = home .. "/.cache/jdtls/workspace/" .. project_name
local path_to_jdtls = home .. "/.local/share/nvim/mason/packages/jdtls"
local os_type = vim.fn.has("macunix") == 1 and "mac" or "linux"
local path_to_jar = vim.fs.find(function(name)
	return name:match("org.eclipse.equinox.launcher_.*%.jar$")
end, { path = path_to_jdtls .. "/plugins/", type = "file" })[1]

local config = {
	cmd = {
		"java",
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-Xmx1g",
		"-javaagent:" .. path_to_jdtls .. "/lombok.jar",
		"--add-modules=ALL-SYSTEM",
		"--add-opens", "java.base/java.util=ALL-UNNAMED",
		"--add-opens", "java.base/java.lang=ALL-UNNAMED",
		"-jar", path_to_jar,
		"-configuration", path_to_jdtls .. "/config_" .. os_type,
		"-data", workspace_dir,
	},
	root_dir = root_dir,
	capabilities = {
		workspace = { configuration = true },
		textDocument = { completion = { completionItem = { snippetSupport = true } } },
	},
	settings = {
		java = {
			references = { includeDecompiledSources = true },
			eclipse = { downloadSources = true },
			maven = { downloadSources = true },
			sources = {
				organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 },
			},
		},
	},
}

jdtls.start_or_attach(config)
