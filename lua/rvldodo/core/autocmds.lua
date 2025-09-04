-- vim.api.nvim_create_augroup("jdtls_lsp", { clear = true })
--
-- vim.api.nvim_create_autocmd("FileType", {
--    group = "jdtls_lsp",
--    pattern = "java",
--    callback = function()
--       require("rvldodo.core.jdtls").setup_jdtls()
--    end,
-- })

---------------------
-- Visual Mode Enhancements -------------------

-- Enhanced visual selection feedback
vim.api.nvim_create_augroup("VisualEnhancements", { clear = true })

-- Show visual selection count
vim.api.nvim_create_autocmd("ModeChanged", {
   group = "VisualEnhancements",
   pattern = "*:v*",
   callback = function()
      vim.defer_fn(function()
         if vim.fn.mode():find("v") then
            local start_pos = vim.fn.getpos("v")
            local end_pos = vim.fn.getpos(".")
            local lines = math.abs(end_pos[2] - start_pos[2]) + 1
            local chars
            
            if vim.fn.mode() == "V" then
               chars = vim.fn.line("$") - vim.fn.line(".") + 1
               vim.notify(string.format("Visual Line: %d lines", lines), vim.log.levels.INFO, {
                  title = "Selection",
                  timeout = 1000,
               })
            elseif vim.fn.mode() == "\x16" then -- Visual block mode
               local cols = math.abs(end_pos[3] - start_pos[3]) + 1
               vim.notify(string.format("Visual Block: %dx%d", lines, cols), vim.log.levels.INFO, {
                  title = "Selection",
                  timeout = 1000,
               })
            else
               local selection = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
               chars = 0
               for _, line in ipairs(selection) do
                  chars = chars + string.len(line)
               end
               vim.notify(string.format("Visual: %d chars, %d lines", chars, lines), vim.log.levels.INFO, {
                  title = "Selection",
                  timeout = 1000,
               })
            end
         end
      end, 10)
   end,
})

-- Clear notification when leaving visual mode
vim.api.nvim_create_autocmd("ModeChanged", {
   group = "VisualEnhancements",
   pattern = "v*:*",
   callback = function()
      if not vim.fn.mode():find("v") then
         -- Clear previous notifications
         vim.notify("", vim.log.levels.INFO, {
            title = "Selection",
            timeout = 1,
         })
      end
   end,
})
