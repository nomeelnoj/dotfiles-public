local ls = require("luasnip")
local parser = ls.parser

ls.add_snippets(nil, {
  gitcommit = {
    parser.parse_snippet("fix", "fix($1): $2"),
    parser.parse_snippet("feat", "feat($1): $2"),
    parser.parse_snippet("chore", "chore($1): $2"),
    parser.parse_snippet("doc", "doc($1): $2"),
  }
})
