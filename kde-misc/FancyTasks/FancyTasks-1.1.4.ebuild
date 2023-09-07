# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )

inherit python-any-r1 desktop

DESCRIPTION="Make your plasma task manager widget pretty"
HOMEPAGE="https://github.com/alexankitty/FancyTasks"
SRC_URI="https://github.com/alexankitty/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	kde-plasma/plasma-workspace:5
"
RDEPEND="${DEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	sys-devel/gettext
"

src_compile() {
	pushd package/translate >/dev/null
	./merge
	./build
	popd >/dev/null
}

src_install() {
	insinto "/usr/share/plasma/plasmoids/alexankitty.fancytasks"
	doins -r package/contents package/metadata.json
	doicon -s 256 package/${PN}.png
}
