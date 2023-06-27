module main

import os
import arrays

struct R_Package {
	install string
	pkg     string
}

fn install_parse(word string, name string) string {
	// package parse function: pip, R, apt
	check := match true {
		name.contains('R') { ['R', '', '--no-save', '', '-e', ''] }
		name.contains('pip') { ['pip', '', 'install', ''] }
		name.contains('apt') { ['apt', ''] }
		else { [''] }
	}
	valid := word.replace_each(check).trim_space()
	return valid
}

fn r_package_parse(items []string) map[string][]string {
	data := items.filter(fn (item string) bool {
		return item.contains('R ')
	})
	lines := data.map(fn (word string) []R_Package {
		pkg := install_parse(word, 'R')
		trim_pkg := pkg.replace_each(['"', '', "'", ''])
		install_name := trim_pkg.all_before('(')
		pkg_name := trim_pkg.all_after('(').trim('c(').all_before(')').split(',')
		return pkg_name.map(R_Package{ install: install_name, pkg: it })
	})
	pkg_line := arrays.flatten(lines)
	mut grouped_line := map[string][]string{}
	for item in pkg_line {
		grouped_line[item.install] << item.pkg
	}
	return grouped_line
}

fn main() {
	file := os.read_file('R.sh') or { panic(err) }
	data := file.split('RUN').filter(!it.is_blank()).map(it.trim_space())
	lines := data.map(it.replace_each(['\n', '', '\\', '']))
	pkgs := r_package_parse(lines)
	println(pkgs)
}
