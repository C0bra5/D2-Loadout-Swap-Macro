import os, subprocess
from os import path

# curse you vs code and your stupid cwd ignoring behaviour
CWD = path.split(__file__)[0]
OUT_DIR = path.join(CWD, "build")
TESTER_DIR = path.join(CWD, "tester")
COMPILED_SCRIPT_NAME = "D2-Loadout-Swapper"
COMPILED_TESTER_NAME = "standalone-tester"
AHK2EXE_PATH = R"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"
COMPILATIONS = (
	(COMPILED_SCRIPT_NAME + "-32bit", R"C:\Program Files\AutoHotkey\v2\AutoHotkey32.exe"),
	(COMPILED_SCRIPT_NAME + "-64bit", R"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe")
)

def get_tag_or_commit():
	# get the current tag or commit hash
	tag_or_commit = subprocess.check_output(['git', 'tag', '--points-at', 'HEAD']).decode('utf8').strip()
	if tag_or_commit == "":
		tag_or_commit = subprocess.check_output(['git', 'rev-parse', '--short', 'HEAD']).decode('utf8').strip()

	# check if there are uncommited changes 
	is_dirty = subprocess.check_output(['git', 'rev-parse', '--short', 'HEAD']).decode('utf8').strip() == ""
	if not is_dirty:
		tag_or_commit += "-dirty"
		
	return tag_or_commit

def build_standalone_tester(tag_or_commit):
	with open(path.join(TESTER_DIR, "index.html"), "r") as file_html, open(path.join(TESTER_DIR, "main.js"), "r") as file_js:
		html = file_html.read()
		js = file_js.read()

	# include the script directly
	replacement = '<script defer="true" id="standaloneScript">'
	replacement += js
	replacement += '</script>'
	# style the loadout slots because otherwize they are impossible to find without a bg.
	replacement += '<style>.loadout-slot {fill: rgba(0,0,0,0.75);}</style>'
	to_write = html.replace('<script src="./main.js" defer="true"></script>', replacement)
	# write head to tester document title
	to_write = to_write.replace("</title>", " " + tag_or_commit +"</title>")

	# write back the standalone tester to it's own file
	with open(path.join(OUT_DIR, COMPILED_TESTER_NAME + "-" + tag_or_commit + ".html"), "w", encoding="utf8") as file_standalone:
		file_standalone.write(to_write)
		file_standalone.flush()

def compile_scripts(tag_or_commit):
	for comp_args in COMPILATIONS:
		subprocess.run([
			AHK2EXE_PATH,
			"/in",       path.join(CWD, "Main.ahk"),
			"/icon",     path.join(CWD, "icon.ico"),
			"/out",      path.join(OUT_DIR, comp_args[0] + "-" + tag_or_commit + ".exe"),
			"/base",     comp_args[1],
			"/compress", "0"
		], capture_output=True)

def main():
	# create the output folder if it doesn't exist
	if not path.isdir(OUT_DIR):
		os.mkdir(OUT_DIR)

	# generate releases
	tag_or_commit = get_tag_or_commit()
	build_standalone_tester(tag_or_commit)
	compile_scripts(tag_or_commit)

if __name__ == "__main__":
	main()