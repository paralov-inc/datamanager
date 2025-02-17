local t = require(script.Parent.Parent.Packages.T)

local template = {
	Currency = {
		Dollar = 0,
		Cents = 0,
	},
	Test = "Hello",
}

local schema = t.strictInterface({
	Currency = t.strictInterface({
		Dollar = t.numberMin(0),
		Cents = t.numberMin(0),
	}),
	Test = t.string,
})

assert(schema(template), "Profile template is invalid")

export type ProfileTemplate = typeof(template)

return {
	template = template,
	schema = schema,
}
