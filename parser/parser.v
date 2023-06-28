module parser

import arrays

struct R_Package {
	install string
	pkg     string
}

fn normalize_spaces(input string) string {
	return input.trim_space().split(' ').filter(!it.is_blank()).join(' ')
}

pub fn apt_package_parse(lines []string) []string {
	items := lines.filter(fn (line string) bool {
		return !line.contains_any_substr(['pip ', 'R '])
	})
	pkg := items.map(it.split(' ').filter(!it.is_blank()).join(' '))
	return pkg
}

pub fn pip_package_parse(lines []string) []string {
	items := lines.filter(fn (line string) bool {
		return line.contains('pip ')
	})
	pkgs := items.map(install_parse(it, 'pip').replace("'", '').split(' '))
	data := arrays.flatten(pkgs)
	names := data.filter(!it.starts_with('-'))
	mut unique := []string{}
	for item in names {
		base_pkg := item.split('==')[0]
		if base_pkg !in unique {
			unique << item
		}
	}
	return unique
}

fn install_parse(word string, name string) string {
	check := match true {
		name.contains('R') { ['R', '', '--no-save', '', '-e', '', '--no save', ''] }
		name.contains('pip') { ['pip', '', 'install', ''] }
		else { [''] }
	}
	valid := normalize_spaces(word.replace_each(check))
	return valid
}

fn r_package_parse(word string) []R_Package {
	pkg := install_parse(word, 'R').split(';').filter(!it.contains_any_substr([
		'library',
		'usethis',
	])).join('')
	trim_pkg := pkg.replace_each(['"', '', "'", ''])
	install_name := trim_pkg.all_before('(').trim_space()
	pkg_name := trim_pkg.find_between('(', ')').trim('c(')
	parsed_pkg := if pkg_name.contains('=') {
		[pkg_name.all_before(')')]
	} else if pkg_name.is_blank() {
		[]string{}
	} else {
		pkg_name.all_before(')').split(',')
	}
	return parsed_pkg.map(R_Package{
		install: install_name
		pkg: it.trim_space()
	})
}

pub fn r_package_collect(items []string) map[string][]string {
	data := items.filter(fn (item string) bool {
		return item.contains('R ')
	})
	lines := data.map(r_package_parse)
	pkg_line := arrays.flatten(lines)
	mut grouped_line := map[string][]string{}
	mut list_pkgs := []string{}
	for item in pkg_line {
		if !item.install.contains('<-') && item.pkg !in list_pkgs {
			list_pkgs << item.pkg
			grouped_line[item.install] << item.pkg
		}
	}
	return grouped_line
}
