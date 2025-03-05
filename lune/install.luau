local process = require("@lune/process")
local fs = require("@lune/fs")

local function installWallyPackages()
	for _, path in { "ServerPackages", "Packages", "wally.lock" } do
		if fs.isDir(path) then
			fs.removeDir(path)
		elseif fs.isFile(path) then
			fs.removeFile(path)
		end
	end

	local result = process.spawn("wally", { "install" })
	if result.ok then
		print("Installed Wally packages")
	else
		print("Failed to install Wally packages")
		print(result.stderr)
		process.exit(result.code)
	end
end

local function createRojoSourcemap()
	local result = process.spawn("rojo", { "sourcemap", "-o", "sourcemap.json" })
	if result.ok then
		print("Created Rojo sourcemap")
	else
		print("Failed to create Rojo sourcemap")
		print(result.stderr)
		process.exit(result.code)
	end
end

local function createPackageTypes()
	for _, directory in { "Packages", "ServerPackages" } do
		if not fs.isDir(directory) then
			print(directory .. " directory does not exist")
			continue
		end

		local result = process.spawn("wally-package-types", { "--sourcemap", "sourcemap.json", directory })
		if result.ok then
			print("Created package types")
		else
			print("Failed to create package types")
			print(result.stderr)
			process.exit(result.code)
		end
	end
end

installWallyPackages()
createRojoSourcemap()
createPackageTypes()
