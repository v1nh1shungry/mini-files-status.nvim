---@type string?
local git_root = nil

---@class MiniFilesGitStatus
---@field index string
---@field workspace string
---
---@type table<string, MiniFilesGitStatus>
local git_status = {}

local priority = type(vim.g.mini_files_git_status_priority) == "table" and vim.g.mini_files_git_status_priority
  or { " ", "!", "?", "T", "D", "C", "R", "A", "M", "U" }

for k, v in pairs(priority) do
  priority[v] = k
end

---@param lines string[]
local function parse(lines)
  git_status = {}

  for _, line in ipairs(lines) do
    ---@type MiniFilesGitStatus
    local status = {
      index = line:sub(1, 1),
      workspace = line:sub(2, 2),
    }

    local path
    local _, rename_mark = line:find("->")
    if rename_mark then
      path = line:sub(rename_mark + 2)
    else
      path = line:sub(4)
    end

    git_status[vim.fs.normalize(vim.fs.joinpath(git_root, path))] = status

    for dir in vim.fs.parents(path) do
      local normalized_path = vim.fs.normalize(vim.fs.joinpath(git_root, dir))
      local old_status = git_status[normalized_path]
      if old_status then
        if priority[old_status.index] < priority[status.index] then
          git_status[normalized_path].index = status.index
        end
        if priority[old_status.workspace] < priority[status.workspace] then
          git_status[normalized_path].workspace = status.workspace
        end
      else
        git_status[normalized_path] = vim.deepcopy(status)
      end
    end
  end
end

---@type vim.SystemObj?
local job = nil

local function update_git_status()
  if job and not job:is_closing() then
    return
  end

  job = vim.system({
    "git",
    "-c",
    "status.relativePaths=false",
    "status",
    "--short",
  }, { text = true }, function(out)
    if out.code ~= 0 then
      vim.notify("Failed to get git status: " .. out.stderr, vim.log.levels.ERROR, { title = "mini.files.status" })
      return
    end

    parse(vim.split(out.stdout, "\n", { trimempty = true }))
  end)

  return job
end

---@type integer
local ns = vim.api.nvim_create_namespace("mini_files_status_extmarks")

---@param buf integer
local function render_git_status(buf)
  if job and not job:is_closing() then
    job:wait()
  end

  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

  for i, l in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    local entry = require("mini.files").get_fs_entry(buf, i)
    if entry then
      local status = git_status[entry.path]
      if status then
        vim.api.nvim_buf_set_extmark(buf, ns, i - 1, #l, {
          virt_text = {
            { "[", "Comment" },
            { status.index, "MiniFilesGitIndex" },
            { status.workspace, "MiniFilesGitWorkspace" },
            { "]", "Comment" },
          },
        })
      end
    end
  end
end

local augroup = vim.api.nvim_create_augroup("mini_files_status_autocmds", {})

local function initialize()
  vim.api.nvim_create_autocmd("User", {
    callback = function()
      update_git_status()
    end,
    group = augroup,
    pattern = { "MiniFilesExplorerOpen", "MiniFilesAction*" },
  })

  vim.api.nvim_create_autocmd("User", {
    callback = function(arg)
      -- make sure render the buffer after the status is updated
      vim.defer_fn(function()
        if job then
          render_git_status(arg.data.buf_id)
        else
          vim.notify("No background git process", vim.log.levels.ERROR, { title = "mini.files.status" })
        end
      end, 50)
    end,
    group = augroup,
    pattern = "MiniFilesBufferUpdate",
  })
end

local function deinitialize()
  vim.api.nvim_clear_autocmds({ group = augroup })
end

local function setup()
  git_root = vim.fs.root(vim.uv.cwd() or 0, ".git")

  if git_root then
    initialize()
  else
    deinitialize()
  end
end

vim.api.nvim_create_autocmd({ "DirChanged" }, {
  callback = setup,
  group = vim.api.nvim_create_augroup("mini_files_status_setup_autocmd", {}),
})

setup()
