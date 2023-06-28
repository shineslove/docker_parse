module main

import os
import parser
import arrays

fn collect_lines() []string {
	mut lines := []string{}
	path := os.args[1] or { '.' }
	files := os.walk_ext(path, '.sh')
	for item in files {
		file := os.read_file(item) or { panic(err) }
		data := file.split('RUN').filter(!it.is_blank()).map(it.trim_space())
		pkgs := arrays.flatten(data.map(it.replace_each(['\n', '', '\\', '']).split('&&')))
		lines << pkgs
	}
	return lines
}

fn main() {
	installs := collect_lines()
	pkgs := parser.r_package_collect(installs)
    // window array in map and write out to Dockerfile
	println(pkgs)
}
