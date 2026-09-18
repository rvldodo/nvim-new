-- Single-file compile & run for C / C++.
--
-- A CMake project gets <leader>cb / <leader>cR from cmake-tools (plugins/cpp.lua),
-- but a scratch file or an exercise has no project to build. Compile the current
-- buffer to a cache dir and run it in a split terminal.
--
-- Sanitizers are on by default: for the size of program you write in a single
-- file, the runtime cost is irrelevant and it turns silent memory corruption
-- into an immediate, readable stack trace.

vim.api.nvim_create_autocmd("FileType", {
   group = vim.api.nvim_create_augroup("CppQuickRun", { clear = true }),
   pattern = { "c", "cpp" },
   callback = function(ev)
      vim.keymap.set("n", "<leader>cc", function()
         local is_cpp = vim.bo[ev.buf].filetype == "cpp"
         local src = vim.fn.expand("%:p")
         if src == "" then
            vim.notify("Buffer has no file on disk", vim.log.levels.WARN)
            return
         end

         local out_dir = vim.fn.stdpath("cache") .. "/nvim-cpp-run"
         vim.fn.mkdir(out_dir, "p")
         local out = out_dir .. "/" .. vim.fn.expand("%:t:r")

         local compiler = is_cpp and "c++" or "cc"
         local std = is_cpp and "-std=c++20" or "-std=c17"

         vim.cmd("write")
         vim.cmd(
            ("botright 15split | terminal %s %s -g -Wall -Wextra -fsanitize=address,undefined %s -o %s && %s"):format(
               compiler,
               std,
               vim.fn.shellescape(src),
               vim.fn.shellescape(out),
               vim.fn.shellescape(out)
            )
         )
         vim.cmd("startinsert")
      end, { buffer = ev.buf, desc = "C/C++: compile & run this file" })
   end,
})
