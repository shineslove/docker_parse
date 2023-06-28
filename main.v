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

fn write_dockerfile_r(run_pkgs map[string][]string, size int) {
	mut file := os.create('Dockerfile') or { panic(err) }
	defer {
		file.close()
	}
	for install, package in run_pkgs {
		split_pkgs := arrays.chunk(package, size)
		for pkg in split_pkgs {
			quoted_pkgs := pkg.map('\'${it}\'').join(',')
			file.writeln('RUN R --no-save -e ${install}(c(${quoted_pkgs}))') or { panic(err) }
		}
	}
}

fn main() {
    // TODO: implement pip packages
	installs := collect_lines()
	pkgs := parser.r_package_collect(installs)
	write_dockerfile_r(pkgs, 8)
}
