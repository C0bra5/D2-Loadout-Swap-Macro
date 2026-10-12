from os import path

if __name__ == "__main__":
	# curse you vs code and your stupid cwd ignoring behaviour
	cwd = path.split(__file__)[0]
	with open(path.join(cwd, "index.html"), "r") as file_html, open(path.join(cwd, "main.js"), "r") as file_js:
		html = file_html.read()
		js = file_js.read()

	# include the script directly
	replacement = '<script defer="true" id="standaloneScript">'
	replacement += js
	replacement += '</script>'
	# style the loadout slots because otherwize they are impossible to find without a bg.
	replacement += '<style>.loadout-slot {fill: rgba(0,0,0,0.75);}</style>'
	to_write = html.replace('<script src="./main.js" defer="true"></script>', replacement)

	# write back the standalone tester to it's own file
	with open(path.join(cwd, "standalone-tester.html"), "w", encoding="utf8") as file_standalone:
		file_standalone.write(to_write)
		file_standalone.flush()