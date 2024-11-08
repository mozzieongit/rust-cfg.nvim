<p align="center">
<img src="assets/rust-cfg.nvim.png" width="25%" alt="rust-cfg.nvim logo" title="logo" />
</p>

# rust-cfg.nvim

## Description

This plugin simplifies the process of configuring rust-analyzer targets and features by providing an interactive interface using Telescope.

## Installation

You can install this plugin using your favorite plugin manager. 
For example, using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use ({
  'babidiii/rust-cfg.nvim',
  requires = {
    'nvim-telescope/telescope.nvim', 
    'nvim-lua/plenary.nvim', 
    'simrat39/rust-tools.nvim', 
  },
  opt = false,
  config = function() 
    require('rust_cfg').setup({ get_settings = function()
      return your_global_settings_object_or_whereever_its_stored
    end)
    require('telescope').load_extension('rust_cfg') 
  end
})

```

## Usage
To use this plugin, simply run `Telescope rust_cfg features` or `Telescope rust_cfg targets`. 
This will open an interactive Telescope interface that allows you to select the features or the targets for your rust-analyzer configuration.
The plugin will then restart the Language Server Protocol in order to start with the selected targets and features.

### Mappings

```lua
local map = vim.api.nvim_set_keymap 
local opts = { noremap = true}

map('n','<leader>cf','<cmd>Telescope rust_cfg features<cr>',opts)
map('n','<leader>ct','<cmd>Telescope rust_cfg targets<cr>',opts)
```

## License
This plugin is licensed under the MIT License.

## Contributing
If you would like to contribute to this plugin, please submit a pull request with your changes. 

## Support
If you encounter any issues or have any questions about this plugin, please submit an issue on the [project's GitHub page](https://github.com/babidiii/rust-cfg.nvim/issues).
