local Sift = require(script.Parent.Parent.Packages.Sift)

--[[
	Reconciles a target table with a template table.

	@param target any -- The table to reconcile.
	@param template any -- The template to reconcile the target with.
]]
local function reconcile(target: any, template: any)
	if type(target) ~= "table" or type(template) ~= "table" then
		warn("Reconciliation can only be done to tables")
		return
	end

	for k, v in pairs(template) do
		-- Only string keys will be reconciled
		if type(k) ~= "string" then
			continue
		end

		-- If the key doesn't exist on the target table, create it
		if target[k] == nil then
			target[k] = type(v) == "table" and Sift.Dictionary.copyDeep(v) or v
			continue
		end

		-- If either the target or template value is not a table, skip
		if type(target[k]) ~= "table" or type(v) ~= "table" then
			continue
		end

		-- Recursively reconcile the table
		reconcile(target[k], v)
	end
end

return reconcile
