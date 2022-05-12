# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..10} )
inherit desktop systemd python-single-r1

DESCRIPTION="A container-based approach to boot a full Android system on a regular Linux system"
HOMEPAGE="https://waydro.id"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/waydroid/waydroid.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/waydroid/waydroid/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3"
SLOT="0"

IUSE="clipboard"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="
	clipboard? ( dev-python/pyclip )
	app-containers/lxc
	$(python_gen_cond_dep '
		dev-python/pygobject[${PYTHON_USEDEP}]
		dev-python/gbinder[${PYTHON_USEDEP}]
	')
	net-firewall/nftables
	net-dns/dnsmasq
	${PYTHON_DEPS}
"
RDEPEND="${DEPEND}"
BDEPEND=""

src_configure() {
	sed -i -e 's:/usr/lib/waydroid/data/AppIcon.png:waydroid:g' "${S}/data/Waydroid.desktop"
}

src_install() {
	#Main files
	python_fix_shebang waydroid.py
	mv waydroid.py waydroid || die
	python_doscript waydroid
	python_domodule tools
	python_domodule data

	#adjust permissions
	fperms +x "$(python_get_sitedir)/data/scripts/waydroid-net.sh"

	#Desktop
	domenu "${S}/data/Waydroid.desktop"
	newicon --size 512 "${S}/data/AppIcon.png" waydroid.png

	#Config files
	insinto /etc/gbinder.d
	doins "${S}/gbinder/anbox.conf"
	insinto /etc
	doins "${FILESDIR}/gbinder.conf"

	#Systemd service
	systemd_dounit "${S}/debian/waydroid-container.service"
}
