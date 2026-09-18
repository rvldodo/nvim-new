-- Neovim types every *.html as `html`. In a Django or Flask project that means
-- template tags render as plain text and the html LSP flags `{% block %}` as a
-- syntax error. Re-type those buffers as `htmldjango`, which has a Treesitter
-- parser that understands both Django and Jinja tag syntax.

vim.filetype.add({
   extension = {
      jinja = "jinja",
      jinja2 = "jinja",
      j2 = "jinja",
   },
   filename = {
      ["requirements.txt"] = "requirements",
      ["requirements-dev.txt"] = "requirements",
      ["constraints.txt"] = "requirements",
      ["Pipfile"] = "toml",
   },
   pattern = {
      -- Convention in both frameworks: templates live under a templates/ dir.
      [".*/templates/.*%.html"] = "htmldjango",
      ["requirements.*%.txt"] = "requirements",
   },
})

-- The path convention above covers most files, but not templates kept
-- elsewhere. Fall back to sniffing the head of the buffer for tag syntax.
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
   group = vim.api.nvim_create_augroup("PythonTemplateDetect", { clear = true }),
   pattern = "*.html",
   callback = function(ev)
      if vim.bo[ev.buf].filetype == "htmldjango" then
         return
      end
      for _, line in ipairs(vim.api.nvim_buf_get_lines(ev.buf, 0, 40, false)) do
         -- `{% ... %}` (block/extends/if) or `{{ ... }}` (interpolation).
         if line:match("{%%%-?%s*%a") or line:match("{{.-}}") then
            vim.bo[ev.buf].filetype = "htmldjango"
            return
         end
      end
   end,
})
