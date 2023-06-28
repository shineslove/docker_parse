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

fn write_dockerfile(pkgs []string) {
	mut file := os.create('Dockerfile') or { panic(err) }
	defer {
		file.close()
	}
	for pkg in pkgs {
		file.writeln(pkg) or { panic(err) }
	}
}

fn docker_format_r(run_pkgs map[string][]string, size int) []string {
	mut instructions := []string{}
	for install, package in run_pkgs {
		split_pkgs := arrays.chunk(package, size)
		for pkg in split_pkgs {
			quoted_pkgs := pkg.map('\'${it}\'').join(',')
			instructions << 'RUN R --no-save -e ${install}(c(${quoted_pkgs}))'
		}
	}
	return instructions
}

fn docker_format_pip(pip_pkgs []string, size int) []string {
	mut instructions := []string{}
	split_pkgs := arrays.chunk(pip_pkgs, size)
	for pkg in split_pkgs {
		instructions << 'RUN pip install ${pkg.join(' ')}'
	}
	return instructions
}

fn docker_format_apt(apt_pkgs []string) []string {
	return ['RUN ${apt_pkgs.join(' && ')}']
}

fn main() {
	installs := collect_lines()
	pip_pkgs := parser.pip_package_parse(installs)
	pip_docker := docker_format_pip(pip_pkgs, 5)
	r_pkgs := parser.r_package_collect(installs)
	r_docker := docker_format_r(r_pkgs, 8)
	apt_pkgs := parser.apt_package_parse(installs)
	apt_docker := docker_format_apt(apt_pkgs)
	write_dockerfile(arrays.flatten([r_docker, pip_docker, apt_docker]))
}
