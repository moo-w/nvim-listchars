local api = require("nvim-listchars.api")
local config_mgr = require("nvim-listchars.config")
local cache = require("nvim-listchars.cache")

---@class NvimListchars
---@field private resolved_config PluginConfig
local M = {}

---Create user commands belonging to this plugin
local function create_user_commands()
	vim.api.nvim_create_user_command("ListcharsStatus", api.recall, { desc = "Prints listchars table" })
	vim.api.nvim_create_user_command("ListcharsToggle", api.toggle_listchars, { desc = "Toggle listchars ON/OFF" })
	vim.api.nvim_create_user_command("ListcharsDisable", function()
		api.toggle_listchars({ "disabled", api.get_highlights()["Whitespace"]["fg"] })
	end, { desc = "Disable listchars" })
	vim.api.nvim_create_user_command("ListcharsEnable", function()
		api.toggle_listchars({ "enabled", api.get_highlights()["Whitespace"]["fg"] })
	end, { desc = "Enable listchars" })
	vim.api.nvim_create_user_command("ListcharsClearCache", cache.clear, { desc = "Clear nvim-listchars state cache" })
	vim.api.nvim_create_user_command("ListcharsLightenColors", function()
		api.lighten_colors(config_mgr.config.lighten_step)
	end, { desc = "Lighten listchar colors" })
	vim.api.nvim_create_user_command("ListcharsDarkenColors", function()
		api.lighten_colors(-config_mgr.config.lighten_step)
	end, { desc = "Darken listchar colors" })
end

---Create autocmds belonging to this plugin
local function create_autocmds()
	local listchars_group = vim.api.nvim_create_augroup("NvimListchars", { clear = true })
	vim.api.nvim_create_autocmd("BufEnter", {
		desc = "disable listchars on specific filetypes",
		group = listchars_group,
		callback = function(o)
			if vim.tbl_contains(config_mgr.config.exclude_filetypes, vim.bo[o.buf].filetype) then
				vim.opt.list = false
			end
		end,
	})
end

---Setup NvimListchars
---@param opts? PluginConfig
function M.setup(opts)
	config_mgr.setup(opts)

	if vim.opt.list:get() and config_mgr.config.save_state then
		local save_state = cache.read()
		api.toggle_listchars(save_state)
	end

	create_user_commands()
	create_autocmds()
end

return M
