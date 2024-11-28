# mini-files-status.nvim

Add Git status to [mini.files](https://github.com/echasnovski/mini.files).

mini.files has been always my favorite file explorer since it was released. It combines [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim)'s power of file navigation and [oil.nvim](https://github.com/stevearc/oil.nvim)'s power file manipulation. However the plugin itself has only the very core features,
and Evgeni promised information like git status can be done by users and therefore would never be out-of-box in the plugin. Yeah we sure can make one.

![demo](https://private-user-images.githubusercontent.com/98312435/390727783-f8e35bbc-7a3d-4611-a169-99d756838c32.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MzI3ODczODMsIm5iZiI6MTczMjc4NzA4MywicGF0aCI6Ii85ODMxMjQzNS8zOTA3Mjc3ODMtZjhlMzViYmMtN2EzZC00NjExLWExNjktOTlkNzU2ODM4YzMyLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDExMjglMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQxMTI4VDA5NDQ0M1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTU3M2ViNWRhNjU1Y2I3YTE3ZmJlMjBlNWMxNjljYWIxYTg0MDBiNThiM2YxMDRmYjRhMjVjMDBiZGY2NjQ1YmYmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.Es3Qk85mSujMA8p8wNOIB5URmVvLmAqrmyhZ-z_R41Y)

This plugin brings mini.files extra git status information. Indeed it uses `git status --short`, if you run this command in your git repository, it is probably like this

```bash
$ git status --short
 M ../README.md
 M lazy-lock.json
 M lua/dotfiles/plugins/extra/lang/nlua.lua
 M lua/dotfiles/plugins/ui.lua
D  plugin/mini-files-git.lua
 M plugin/task.lua
```

You see there're two columns of status, which stand for status of index and current workspace, you can check more details in `man git-status`, the `Short Format` section.

# Installation

Requires NVIM >= 0.10.

[lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "echasnovski/mini.files",
    dependencies = "v1nh1shungry/mini-files-status.nvim",
}
```

# Configuration

* `vim.g.mini_files_git_status_priority`

Default: `{ " ", "!", "?", "T", "D", "C", "R", "A", "M", "U" }`

For example, if files are staged and deleted in the same directory, what status do you expect for this directory? `A` or `D`? This global variable is used to determine the priority, the priority is higher from left to right.

# Highlight Groups

|        Index        |        Workspace        |
|:-------------------:|:-----------------------:|
| `MiniFilesGitIndex` | `MiniFilesGitWorkspace` |

Demo uses `GitSignsAdd` and `GitSignsChange` in theme [tokyonight](https://github.com/folke/tokyonight.nvim).

# Planned Features

* Use highlight instead of virtual text.

I had thought about it, but it's hard for me to pick the right color according to both index and workspace status. But yes, I think highlight must be a more natural way for most people.

* Diagnostic status.

I personally suppose it's not necessary to show diagnostic status in a file explorer, so this will not be implemented unless someone asks for it. Of course, any contributions is welcome :)

# Special Thanks

* [mini.files](https://github.com/echasnovski/mini.files) - Sure my favorite neovim file explorer ever! Besides this plugin will not even exist without it.
* [oil-git-status.nvim](https://github.com/refractalize/oil-git-status.nvim) - Inspires this plugin a lot. Yes, the idea of two-column mark is from this.
