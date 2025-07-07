-- my packages

return {
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		dependencies = {
			{ "ms-jpq/coq_nvim", branch = "coq" },
			{ "ms-jpq/coq.artifacts", branch = "artifacts" },
			{ "ms-jpq/coq.thirdparty", branch = "3p" }
		},

		init = function()
			vim.g.coq_settings = {
				auto_start = true,
			}
		end,

		config = function() 
			vim.lsp.config('rust_analyzer', {
				settings = {
					['rust-analyzer'] = {
						diagnostics = {
							enable = true,
							experimental = {
								enable = true,
							},
						},
						workspace = {
							diagnostics = {
								enable = true,
							},
						},
					},
				},
			})
			vim.lsp.enable('rust_analyzer')
			vim.lsp.buf.document_highlight()
			vim.lsp.buf.format()
		end,

		build = ":COQdeps"
	},

	{
  		"nvim-neo-tree/neo-tree.nvim",
 		branch = "main",
 		dependencies = {
 			"nvim-lua/plenary.nvim",
		    	"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		    	"MunifTanjim/nui.nvim",
		},
		lazy = false, -- neo-tree will lazily load itself
		config = function()
			require("neo-tree")
			vim.keymap.set("n", "<leader>f", ":Neotree float<CR>", { desc = "Open up neotree.", silent = true })
		end
	},

	{
		'windwp/nvim-autopairs',
		event = "InsertEnter",
		config = true,
	},

	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		config = function()
			require("kanagawa").load("wave")
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		branch = 'master',
		lazy = false,
		build = ':TSUpdate',
	}
}


