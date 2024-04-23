# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake xdg

DESCRIPTION="(h)top like task monitor for GPUs and accelerators"
HOMEPAGE="https://github.com/Syllo/nvtop"

if [[ "${PV}" == "9999" ]] ; then
	EGIT_REPO_URI="https://github.com/Syllo/${PN}.git"
	inherit git-r3
else
	SRC_URI="https://github.com/Syllo/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3"
SLOT="0"

IUSE="systemd video_cards_amdgpu video_cards_freedreno video_cards_intel video_cards_nvidia video_cards_panfrost"

RDEPEND="
	sys-libs/ncurses:0=
	video_cards_amdgpu? (
		x11-libs/libdrm[video_cards_amdgpu]
		systemd? ( sys-apps/systemd )
		!systemd? ( virtual/udev )
	)
	video_cards_freedreno? ( x11-libs/libdrm[video_cards_freedreno] )
	video_cards_intel? (
		systemd? ( sys-apps/systemd )
		!systemd? ( virtual/udev )
	)
	video_cards_nvidia? ( x11-drivers/nvidia-drivers )
"

DEPEND="${RDEPEND}"

BDEPEND="
	virtual/pkgconfig
"

src_configure() {
	local mycmakeargs=(
		-DNVIDIA_SUPPORT=$(usex video_cards_nvidia)
		-DAMDGPU_SUPPORT=$(usex video_cards_amdgpu)
		-DINTEL_SUPPORT=$(usex video_cards_intel)
		-DMSM_SUPPORT=$(usex video_cards_freedreno)
		-DPANFROST_SUPPORT=$(usex video_cards_panfrost)
		-DUSE_LIBUDEV_OVER_LIBSYSTEMD=$(usex !systemd)
	)
	cmake_src_configure
}
