return {
  name = "bun",
  builder = function(params)
    local args = { params.script }
    -- For package.json scripts, add "run" prefix
    if
      params.script ~= "install"
      and params.script ~= "add"
      and params.script ~= "remove"
      and params.script ~= "update"
    then
      args = { "run", params.script }
    end

    return {
      cmd = { "bun" },
      args = args,
      components = {
        { "on_output_quickfix", open = true },
        "default",
      },
    }
  end,
  params = {
    script = {
      desc = "Script to run",
      type = "enum",
      choices = function()
        local scripts = {}
        local package_json = vim.fn.getcwd() .. "/package.json"

        if vim.fn.filereadable(package_json) == 1 then
          local content = vim.fn.readfile(package_json)
          local json_str = table.concat(content, "\n")
          local ok, json = pcall(vim.fn.json_decode, json_str)

          if ok and json.scripts then
            for script_name, _ in pairs(json.scripts) do
              table.insert(scripts, script_name)
            end
            table.sort(scripts)
          end
        end

        -- Add common bun commands
        local common_commands = { "install", "add", "remove", "update", "build", "test" }
        for _, cmd in ipairs(common_commands) do
          if not vim.tbl_contains(scripts, cmd) then
            table.insert(scripts, cmd)
          end
        end

        return scripts
      end,
      default = "dev",
    },
  },
  condition = {
    filetype = { "javascript", "typescript", "json", "javascriptreact", "typescriptreact" },
    callback = function()
      local cwd = vim.fn.getcwd()
      local has_package_json = vim.fn.filereadable(cwd .. "/package.json") == 1
      local has_bun_lock = vim.fn.filereadable(cwd .. "/bun.lockb") == 1

      -- Only show bun if both package.json and bun.lockb exist
      return has_package_json and has_bun_lock
    end,
  },
}
