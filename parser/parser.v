module parser

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

fn r_package_parse(word string) []R_Package {
	pkg := install_parse(word, 'R')
	trim_pkg := pkg.replace_each(['"', '', "'", ''])
	install_name := trim_pkg.all_before('(')
	pkg_name := trim_pkg.all_after('(')
	parsed_pkg := if pkg_name.contains('=') {
		[pkg_name.all_before(')')]
	} else {
		pkg_name.trim('c(').all_before(')').split(',')
	}
	return parsed_pkg.map(R_Package{ install: install_name, pkg: it })
}

pub fn r_package_collect(items []string) map[string][]string {
	data := items.filter(fn (item string) bool {
		return item.contains('R ')
	})
	lines := data.map(r_package_parse)
	pkg_line := arrays.flatten(lines)
	mut grouped_line := map[string][]string{}
	for item in pkg_line {
		grouped_line[item.install] << item.pkg
	}
	return grouped_line
}
