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

IUSE="clipboard nftables systemd"
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
	if use nftables; then
		sed -i '/LXC_USE_NFT=/ s/false/true/' "${S}/data/scripts/waydroid-net.sh"
	fi
	sed -i -e 's:/usr/lib/waydroid/data/AppIcon.png:waydroid:g' "${S}/data/Waydroid.desktop"
}

src_install() {
	#Main files
	python_newscript waydroid.py waydroid
	python_domodule tools
	python_domodule data

	#adjust permissions
	fperms +x "$(python_get_sitedir)/waydroid/data/scripts/waydroid-net.sh"

	#Desktop
	domenu "${S}/data/Waydroid.desktop"
	newicon --size 512 "${S}/data/AppIcon.png" waydroid.png

	#Config files
	insinto /etc
	doins "${FILESDIR}/gbinder.conf"

	#Systemd service
	if use systemd; then
		systemd_dounit "${S}/systemd/waydroid-container.service"
	fi
}

pkg_postinst() {
	einfo "Waydroid currently doesn't work with AppArmor."
	einfo "You have to either configure rules yourself or"
	einfo "disable AppArmor while running the container."
}
