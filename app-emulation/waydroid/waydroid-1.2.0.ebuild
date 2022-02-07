# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop systemd

DESCRIPTION="A container-based approach to boot a full Android system on a regular Linux system"
HOMEPAGE="https://github.com/waydroid"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/waydroid/waydroid.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/waydroid/waydroid/archive/refs/tags/${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3"
SLOT="0"

IUSE="clipboard"

DEPEND="
	clipboard? ( dev-python/pyclip )
	app-containers/lxc
	dev-lang/python
	dev-python/gbinder
	dev-python/pygobject
	net-firewall/nftables
	net-dns/dnsmasq
"
RDEPEND="${DEPEND}"
BDEPEND=""

src_configure() {
	sed -i -e 's:/usr/lib/waydroid/data/AppIcon.png:waydroid:g' "${S}/data/Waydroid.desktop"
}

src_install() {
	insinto /usr/lib/waydroid
	doins -r "${S}/tools"
	doins -r "${S}/data"
	doins "${S}/waydroid.py"
	fperms +x "/usr/lib/waydroid/waydroid.py"
	into /usr/bin
	dosym "/usr/lib/waydroid/waydroid.py" "/usr/bin/waydroid"

	domenu "${S}/data/Waydroid.desktop"
	newicon --size 512 "${S}/data/AppIcon.png" waydroid.png

	insinto /etc/gbinder.d
	doins "${S}/gbinder/anbox.conf"
	insinto /etc
	doins "${FILESDIR}/gbinder.conf"

	systemd_dounit "${S}/debian/waydroid-container.service"
}
