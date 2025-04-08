return {
	{
		"neovim/nvim-lspconfig",
		event = { "LspAttach" },
		dependencies = {
			{
				"hrsh7th/cmp-nvim-lsp",
				lazy = true,
			},
			{
				"Hoffs/omnisharp-extended-lsp.nvim",
				lazy = true,
			},
		},
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			capabilities.textDocument.completion.completionItem.snippetSupport = true

			local on_attach = function(client, _)
				client.server_capabilities.documentFormattingProvider = false
				client.server_capabilities.documentRangeFormattingProvider = false

				-- LSP Mappings
				local lsp_mappings = {
					{ "<leader>gd", "vim.lsp.buf.definition()" },
					{ "<leader>k", "vim.lsp.buf.hover()" },
					{ "<leader>rn", "vim.lsp.buf.rename()" },
					{ "<leader>gr", "vim.lsp.buf.references()" },
					{ "<leader>gt", "vim.lsp.buf.type_definition()" },
					{ "<leader>sh", "vim.lsp.buf.signature_help()" },
					{ "<leader>ca", "vim.lsp.buf.code_action()" },
				}

				for _, mapping in ipairs(lsp_mappings) do
					vim.keymap.set(
						"n",
						mapping[1],
						"<Cmd>lua " .. mapping[2] .. "<CR>",
						{ noremap = true, silent = true }
					)
				end

				vim.api.nvim_set_keymap(
					"n",
					"<Leader>d",
					":lua vim.diagnostic.open_float()<CR>",
					{ noremap = true, silent = true }
				)

				-- print("LSP server '" .. client.name .. "' started successfully!")
			end

			local servers = {
				lua_ls = {
					settings = {
						Lua = {
							runtime = {
								version = "LuaJIT",
							},
							diagnostics = {
								globals = { "vim" },
							},
							workspace = {
								library = vim.api.nvim_get_runtime_file("", true),
								checkthirdparty = false,
							},
							telemetry = { enable = false },
						},
					},
				},
				ts_ls = {
					init_options = {
						maxTsServerMemory = 3072,
						single_file_support = true,
					},
				},
				gopls = {
					settings = {
						gopls = { staticcheck = true },
					},
				},
				omnisharp = {
					cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
					filetypes = { "cs" },
					handlers = {
						["textDocument/definition"] = require("omnisharp_extended").definition_handler,
						["textDocument/typeDefinition"] = require("omnisharp_extended").type_definition_handler,
						["textDocument/references"] = require("omnisharp_extended").references_handler,
						["textDocument/implementation"] = require("omnisharp_extended").implementation_handler,
					},
					root_dir = function(fname)
						local root = require("lspconfig.util").root_pattern("*.sln", "*.csproj")(fname)
						return root
					end,
					settings = {
						omnisharp = {
							useModernNet = true,
							enableEditorConfigSupport = true,
							enableMsBuildLoadProjectsOnDemand = true,
							enableImportCompletion = true,
							analyzeOpenDocumentsOnly = true,
							sdkIncludePrereleases = false,
							maxProjectFileCount = 100,
						},
						FormattingOptions = {
							EnableEditorConfigSupport = true,
							OrganizeImports = true,
						},
						RoslynExtensionsOptions = {
							EnableAnalyzersSupport = true,
							EnableImportCompletion = true,
						},
					},
				},
				rust_analyzer = {
					settings = {
						["rust-analyzer"] = {
							cargo = { features = "default" },
							checkOnSave = { command = "clippy" },
							diagnostics = {
								enable = true,
								experimental = { enable = true },
							},
						},
					},
				},

				svelte = {
					cmd = { "svelteserver", "--stdio" },
					filetypes = { "svelte" },
				},

				html = {
					filetypes = {
						"html",
						"css",
						"javascript",
						"typescript",
						"javascriptreact",
						"typescriptreact",
						"vue",
						"svelte",
					},
				},

				cssls = {
					filetypes = { "css", "scss", "less", "svelte" },
				},

				tailwindcss = {
					filetypes = {
						"html",
						"css",
						"javascript",
						"typescript",
						"javascriptreact",
						"typescriptreact",
						"vue",
						"svelte",
					},
				},

				-- jdtls = {
				-- 	root_dir = function(fname)
				-- 		return require("lspconfig.util").root_pattern("pom.xml", "build.gradle", ".git")(fname)
				-- 			or vim.fn.getcwd()
				-- 	end,
				-- 	settings = {
				-- 		java = {
				-- 			signatureHelp = { enabled = true },
				-- 			completion = {
				-- 				favoriteStaticMembers = {
				-- 					"org.junit.Assert.*",
				-- 					"org.hamcrest.Matchers.*",
				-- 					"org.hamcrest.CoreMatchers.*",
				-- 					"java.util.Objects.requireNonNull",
				-- 					"java.util.Objects.requireNonNullElse",
				-- 					"java.util.Collections.emptyList",
				-- 				},
				-- 				filteredTypes = {
				-- 					"com.sun.*",
				-- 					"io.micrometer.shaded.*",
				-- 					"java.awt.*",
				-- 					"jdk.*",
				-- 					"sun.*",
				-- 				},
				-- 			},
				-- 			contentProvider = { preferred = "fernflower" },
				-- 			sources = {
				-- 				organizeImports = {
				-- 					starThreshold = 3,
				-- 					staticStarThreshold = 3,
				-- 				},
				-- 			},
				-- 			codeGeneration = {
				-- 				toString = {
				-- 					template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
				-- 				},
				-- 				useBlocks = true,
				-- 			},
				-- 			eclipse = { downloadSources = true },
				-- 			format = {
				-- 				enabled = true,
				-- 				settings = {
				-- 					profile = "GoogleStyle",
				-- 				},
				-- 			},
				-- 		},
				-- 	},
				-- },

				-- pyright = {
				-- 	settings = {
				-- 		python = {
				-- 			analysis = {
				-- 				typeCheckingMode = "basic",
				-- 				autoSearchPaths = true,
				-- 			},
				-- 		},
				-- 	},
				-- },

				clangd = {
					on_attach = on_attach,
					cmd = {
						"clangd",
						"--background-index",
						"--pch-storage=memory",
						"--all-scopes-completion",
						"--pretty",
						"--header-insertion=never",
						"-j=4",
						"--inlay-hints",
						"--header-insertion-decorators",
						"--function-arg-placeholders",
						"--completion-style=detailed",
					},
					filetypes = { "c", "cpp", "objc", "objcpp" },
					root_dir = require("lspconfig.util").root_pattern("meson.build", "src", "CMakeLists.txt", ".git"),
					init_option = { fallbackFlags = { "-std=c++2a" } },
					capabilities = capabilities,
					settings = {
						["clangd"] = {
							fileStatus = true,
						},
					},
				},

				-- gdscript = {
				-- 	cmd = vim.fn.has("win32") == 1 and { "ncat", "localhost", "6005" }
				-- 		or { "ncat", "localhost", "6005" },
				-- 	flags = { debounce_text_changes = 200 },
				-- },
			}
			for server, config in pairs(servers) do
				config.on_attach = on_attach
				config.capabilities = capabilities
				lspconfig[server].setup(config)
			end
		end,
	},
}
