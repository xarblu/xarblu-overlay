# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..12} )

inherit python-single-r1 systemd

MY_PN="crafty-4"

DESCRIPTION="Minecraft Server Wrapper / Controller / Launcher"
HOMEPAGE="https://craftycontrol.com https://gitlab.com/crafty-controller/crafty-4"
SRC_URI="https://gitlab.com/crafty-controller/${MY_PN}/-/archive/v${PV}/${MY_PN}-v${PV}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	acct-user/crafty
	acct-group/crafty
	|| (
		virtual/jre:1.8
		virtual/jre:11
		virtual/jre:17
	)
	$(python_gen_cond_dep '
		>=dev-python/APScheduler-3.10.4[${PYTHON_USEDEP}]
		>=dev-python/argon2-cffi-23.1.0[${PYTHON_USEDEP}]
		>=dev-python/cached-property-1.5.2[${PYTHON_USEDEP}]
		>=dev-python/colorama-0.4.6[${PYTHON_USEDEP}]
		>=dev-python/croniter-1.4.1[${PYTHON_USEDEP}]
		>=dev-python/cryptography-41.0.7[${PYTHON_USEDEP}]
		>=dev-python/libgravatar-1.0.4[${PYTHON_USEDEP}]
		>=dev-python/nh3-0.2.14[${PYTHON_USEDEP}]
		>=dev-python/packaging-23.2[${PYTHON_USEDEP}]
		>=dev-python/peewee-3.13[${PYTHON_USEDEP}]
		>=dev-python/psutil-5.9.5[${PYTHON_USEDEP}]
		>=dev-python/pyopenssl-23.3.0[${PYTHON_USEDEP}]
		>=dev-python/pyjwt-2.8.0[${PYTHON_USEDEP}]
		>=dev-python/pyyaml-6.0.1[${PYTHON_USEDEP}]
		>=dev-python/requests-2.31.0[${PYTHON_USEDEP}]
		>=dev-python/termcolor-1.1[${PYTHON_USEDEP}]
		>=dev-python/tornado-6.3.3[${PYTHON_USEDEP}]
		>=dev-python/tzlocal-5.1[${PYTHON_USEDEP}]
		>=dev-python/jsonschema-4.19.1[${PYTHON_USEDEP}]
		>=dev-python/orjson-3.9.7[${PYTHON_USEDEP}]
		>=dev-python/prometheus-client-0.17.1[${PYTHON_USEDEP}]
	')
	${PYTHON_DEPS}
"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_PN}-v${PV}"

DEST="/opt/${PN}"

src_prepare() {
	cat > "${PN}.service" <<EOF
[Unit]
Description=Crafty Controller
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=on-failure
RestartSec=3
User=crafty
Group=crafty
WorkingDirectory=${DEST}
ExecStart=${EPYTHON} main.py

[Install]
WantedBy=multi-user.target
EOF
	eapply_user
}

src_install() {
	# install app files
	insinto "${DEST}"
	doins -r app main.py
	python_optimize "${D}/${DEST}"

	# install systemd unit
	systemd_dounit "${PN}.service"

	# install user owned dirs
	for dir in ${DEST}/{backups,logs,servers,app/config,import}; do
		keepdir "${dir}"
		fowners crafty:crafty "${dir}"
	done
}
