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
	SRC_URI="https://github.com/waydroid/waydroid/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3"
SLOT="0"

IUSE="apparmor clipboard nftables systemd"
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
"

DEPEND="
	clipboard? ( dev-python/pyclip )
	app-containers/lxc
	$(python_gen_cond_dep '
		dev-python/pygobject[${PYTHON_USEDEP}]
		dev-python/gbinder[${PYTHON_USEDEP}]
	')
	!nftables? ( net-firewall/iptables )
	nftables? ( net-firewall/nftables )
	net-dns/dnsmasq
	${PYTHON_DEPS}
"
RDEPEND="${DEPEND}"
BDEPEND=""

src_configure() {
	# enable/disable nftables support
	if use nftables; then
		sed -i -e '/LXC_USE_NFT=/ s/false/true/' "${S}/data/scripts/waydroid-net.sh" || die "Enabling nftables failed"
	fi

	#Move non-essential files
	mkdir "${S}/extras"
	mv "${S}/data/"{*.png,*.desktop,*.metainfo.xml} "${S}/extras"

	# change icon names in .desktop files
	for file in "${S}/extras/"*.desktop; do
		sed -i -e 's:/usr/lib/waydroid/data/AppIcon.png:waydroid:g' "${file}" || die "Changing icon paths failed"
	done
}

src_install() {
	# main files
	python_newscript waydroid.py waydroid
	python_domodule tools
	python_domodule data

	# adjust permissions
	fperms +x "$(python_get_sitedir)/data/scripts/waydroid-net.sh"

	# desktop
	domenu "${S}/extras/"*.desktop
	newicon --size 512 "${S}/extras/AppIcon.png" waydroid.png
	insinto /usr/share/metainfo
	doins "${S}/extras/"*.metainfo.xml


	# config files
	insinto /etc
	doins "${FILESDIR}/gbinder.conf"

	# systemd service
	if use systemd; then
		systemd_dounit "${S}/systemd/waydroid-container.service"
	fi

	# AppArmor profiles
	if use apparmor; then
		insinto /etc/apparmor.d
		doins -r "${S}/data/configs/apparmor_profiles/"{adbd,android_app}
		insinto /etc/apparmor.d/lxc
		doins -r "${S}/data/configs/apparmor_profiles/"lxc-waydroid
	fi
}

pkg_postinst() {
	if has_version "<sys-apps/apparmor-1.3.4"; then
		einfo "Waydroid currently doesn't work with AppArmor."
		einfo "You have to either configure rules yourself or"
		einfo "disable AppArmor while running the container."
	fi
}
