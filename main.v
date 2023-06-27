module main

import os
import parser

fn collect_lines() []string {
	mut installs := []string{}
	path := os.args[1] or { '.' }
    files := os.walk_ext(path,".sh")
    for item in files {
        file := os.read_file(item) or { panic(err) }
        data := file.split('RUN').filter(!it.is_blank()).map(it.trim_space())
        lines := data.map(it.replace_each(['\n', '', '\\', '']))
        installs << lines
    }
	return installs
}

fn main() {
    lines := collect_lines()
	pkgs := parser.r_package_collect(lines)
	println(pkgs)
}
