local Config  = {
  SAORI = {
    choice  = [[saori\choice\choice.dll]],
  },
  Replace = {
    {
      before  = [[、]],
      after   = [[、\w9]],
    },
    {
      before  = [[。]],
      after   = [[。\w9\w9]],
    },
  },
  External  = {
  },
}

return Config
