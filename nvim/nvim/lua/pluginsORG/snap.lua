-- Seems like fzf-lua is fast enough
-- stylua: ignore
if true then return {} end

return {
  "Leolainen/snap",
  -- "camspiers/snap",
  -- keys = {
  --     "<leader>sF",
  --     "<leader>sT"
  -- },
  event = "VeryLazy",
  config = function()
    local snap = require("snap")
    local function git_root_path()
      return vim.fn.systemlist("git rev-parse --show-toplevel")[1]
    end

    -- Function to make a path relative to the root
    local function make_relative_path(root, path)
      if path:sub(1, #root) == root then
        return path:sub(#root + 2) -- +2 to remove the leading slash
      end
      return path
    end

    local function git_root_producer(request)
      local cwd = snap.sync(git_root_path)
      -- local current_dir = snap.sync(vim.fn.getcwd)
      local io = snap.get("common.io")

      -- Iterates rg commands output using snap.io.spawn
      for data, err, kill in
        io.spawn("rg", {
          "--line-buffered",
          "--hidden",
          "--ignore-case",
          "--files",
        }, cwd)
      do
        -- If the filter updates while the command is still running
        -- then we kill the process and yield nil
        if request.canceled() then
          kill()
          coroutine.yield(nil)
          -- If there is an error we yield nil
        elseif err ~= "" then
          print("error", err)
          coroutine.yield(nil)
          -- If the data is empty we yield an empty table
        elseif data == "" then
          coroutine.yield({})
          -- coroutine.continue()
          -- If there is data we split it by newline
        else
          local function get_abs_path(line)
            return string.format("%s/%s", cwd, line)
          end

          local results = vim.split(data, "\n", true)
          results = vim.tbl_map(get_abs_path, results)

          coroutine.yield(results)
        end
      end
      return nil
    end

    local function git_root_consumer(producer)
      local cached_producer = snap.get("consumer.cache")(producer)

      local cwd1 = git_root_path()
      local cwd2 = vim.fn.getcwd()
      local relative_path = make_relative_path(cwd1, cwd2)
      print(vim.inspect(relative_path))
      -- Return producer
      return function(request)
        local results = {}

        for data in snap.consume(cached_producer, request) do
          snap.get("common.tbl").acc(results, data)
          snap.continue()
        end

        local results_string = table.concat(vim.tbl_map(tostring, results), "\n")

        if request.filter == "" then
          return coroutine.yield(results)
        else
          local io = snap.get("common.io")
          local cwd = snap.sync(git_root_path)
          -- local cwd = snap.sync(vim.fn.getcwd)
          local stdout = vim.loop.new_pipe(false)
          local fzf = io.spawn("fzf", { "-f", request.filter }, cwd, stdout)
          stdout:write(results_string)
          stdout:shutdown()

          for data, err, kill in fzf do
            if request.canceled() then
              kill()
              coroutine.yield(nil)
            elseif err ~= "" then
              print(vim.inspect(err))
              coroutine.yield(nil)
            elseif data == "" then
              -- snap.continue()
              coroutine.yield({})
            else
              local results_indexed = {}

              for _, result in ipairs(results) do
                result = make_relative_path(cwd, result)
                -- local shortened_result = vim.fn.fnamemodify(result, ":.")
                -- results_indexed[tostring(shortened_result)] = shortened_result
                results_indexed[tostring(result)] = result
              end

              local filtered_results = string.split(data)

              local function result_index(line)
                line = make_relative_path(cwd, line)
                return results_indexed[line]
              end

              coroutine.yield(vim.tbl_map(result_index, filtered_results))
            end
          end

          return nil
        end
      end
    end

    local function trunc(meta_result)
      -- return vim.fn.fnamemodify(meta_result.result, ':h') ..
      -- "/" .. vim.fn.fnamemodify(meta_result.result, ':t')

      local result = meta_result.result
      -- local firstParent = vim.fn.fnamemodify(result, ":p:.:h")
      local filename = vim.fn.fnamemodify(meta_result.result, ":t")
      -- return filename

      local remove_part = vim.fn.fnamemodify(result, ":h:h:h")
      local subbed = string.sub(result, #remove_part + 2)
      -- local root_path = git_root_path()
      -- Escape special characters in root_path for pattern matching
      -- local escaped_root_path = root_path:gsub("([^%w])", "%%%1")
      -- return "../" .. firstParent .. "/" .. filename
      -- return vim.fn.fnamemodify(result, ":s?^" .. git_root_path() .. "/??")
      -- return vim.fn.fnamemodify(result, ":t")

      return "../" .. subbed

      -- if (#result > 80) then
      --     return "..." .. result:sub(#result - 80)
      -- end

      -- return result
      -- return vim.fn.fnamemodify(meta_result.result, ':t')
    end

    -- IMPORTANT!!!
    -- For this consumer to work, one must change the compiled source code in snap/init.lua
    -- Add this function:
    --
    -- local function display(result)
    --   local display_fn
    --   if has_meta(result, "display") then
    --     assert((type(result.display) == "function"), "display meta must be a function")
    --     display_fn = result.display
    --   else
    --     display_fn = tostring
    --   end
    --   return display_fn(result)
    -- end
    --
    -- and replace the table.insert() bit in "write_results" with this
    -- table.insert(partial_results, display(result))
    --
    -- file found in: .local/share/lunarvim/site/pack/lazy/opt/snap/lua/snap/init.lua
    local function display_results(producer)
      return function(request)
        for results in snap.consume(producer, request) do
          if type(results) == "table" then
            if not vim.tbl_islist(results) then
              coroutine.yield(results)
            else
              coroutine.yield(vim.tbl_map(function(result)
                return snap.with_metas(result, {
                  display = trunc,
                })
              end, results))
            end
          else
            coroutine.yield(nil)
          end
        end
      end
    end

    -- IMPORTANT
    -- MUST change line 5 in lua/snap/common/string.lua to
    -- package.loaded[_2amodule_name_2a] = string <-- changed {} to string
    snap.register.map({ "n" }, { "<Leader>sG" }, function()
      snap.run({
        producer = display_results(snap.get("producer.ripgrep.vimgrep").args({
          "--hidden",
          "--ignore-case",
        }, git_root_path())),
        select = snap.get("select.vimgrep").select,
        multiselect = snap.get("select.vimgrep").multiselect,
        views = { snap.get("preview.vimgrep") },
        steps = {
          {
            consumer = snap.get("consumer.fzf"),
            config = { prompt = "FZF>" },
          },
        },
      })
    end)

    snap.register.map({ "n" }, { "<Leader>sF" }, function()
      snap.run({
        producer = display_results(snap.get("consumer.fzf")(snap.get("producer.ripgrep.file").args({
          "--hidden",
          "--ignore-case",
        }, git_root_path()))),
        -- producer = snap.get 'consumer.fzf' (git_root_grep_producer),
        -- producer = git_root_grep_consumer(git_root_grep_producer),
        select = snap.get("select.file").select,
        -- select = custom_select,
        multiselect = snap.get("select.vimgrep").multiselect,
        -- views = { custom_views },
        views = { snap.get("preview.file") },
        steps = {
          {
            consumer = snap.get("consumer.fzf"),
            config = { prompt = "FZF>" },
          },
        },
      })
    end)

    snap.maps({
      { "<Leader>sf", snap.config.file({ producer = "ripgrep.file", prompt = "files" }) },
      { "<Leader>sg", snap.config.vimgrep({ prompt = "grep" }) },
    })
  end,
}
