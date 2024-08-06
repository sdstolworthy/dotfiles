local neotest = require("neotest")
neotest.setup({
  adapters = {
    require('rustaceanvim.neotest')
  },
})
