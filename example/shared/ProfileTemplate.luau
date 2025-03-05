local t = require(script.Parent.Parent.Packages.T)

local template = {
	Currency = {
		Dollar = 0,
		Cents = 0,
	},
	Test = "Hello",
	Nested = {
		Tables = {
			Are = {
				Reconciled = true,
			},
			Reconciled = true,
		},
		Test = {
			Reconciled = true,
		},
		Reconciled = true,
	},
}

local schema = t.strictInterface({
	Currency = t.strictInterface({
		Dollar = t.numberMin(0),
		Cents = t.numberMin(0),
	}),
	Test = t.string,
	Nested = t.strictInterface({
		Tables = t.strictInterface({
			Are = t.strictInterface({
				Reconciled = t.boolean,
			}),
		}),
		Test = t.strictInterface({
			Reconciled = t.boolean,
		}),
		Reconciled = t.boolean,
	}),
})

assert(schema(template), "Profile template is invalid")

export type ProfileTemplate = typeof(template)

return {
	template = template,
	schema = schema,
}
