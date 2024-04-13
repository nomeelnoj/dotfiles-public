local ls = require("luasnip")
local postfix = require("luasnip.extras.postfix").postfix
-- local extras = require("luasnip.extras")

-- some shorthands...
local snip = ls.snippet
-- local node = ls.snippet_node
local text = ls.text_node
-- local insert = ls.insert_node
local func = ls.function_node
-- local choice = ls.choice_node
-- local dynamic = ls.dynamic_node
-- local lambda = extras.lambda


ls.add_snippets(nil, {
	all = {
		postfix(".kv", {
			func(function(_, parent)
				local v = parent.snippet.env.POSTFIX_MATCH
				return "(if ." ..
						v .. "? then reduce (." .. v .. "[] | {(.Key): (.Value)}) as $item ({}; . + $item) else {} end'))", ""
			end, {}),
		}),
	}
})

