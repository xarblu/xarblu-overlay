# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV="$(ver_cut 1-3)-$(ver_cut 4)"

inherit flag-o-matic toolchain-funcs

DESCRIPTION="FFmpeg for Jellyfin"
HOMEPAGE="https://github.com/jellyfin/jellyfin-ffmpeg"
SRC_URI="https://github.com/jellyfin/jellyfin-ffmpeg/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"

SLOT="0"
LICENSE="GPL-3"
KEYWORDS="~amd64 ~arm64"

# only make hwaccel sulutions optional
IUSE="amf cpudetection cuda nvenc opencl +pic qsv test vaapi vulkan"

# Strings for CPU features in the useflag[:configure_option] form
# if :configure_option isn't set, it will use 'useflag' as configure option
ARM_CPU_FEATURES=(
	cpu_flags_arm_thumb:armv5te
	cpu_flags_arm_v6:armv6
	cpu_flags_arm_thumb2:armv6t2
	cpu_flags_arm_neon:neon
	cpu_flags_arm_vfp:vfp
	cpu_flags_arm_vfpv3:vfpv3
	cpu_flags_arm_v8:armv8
)
ARM_CPU_REQUIRED_USE="
	arm64? ( cpu_flags_arm_v8 )
	cpu_flags_arm_v8? ( cpu_flags_arm_vfpv3 cpu_flags_arm_neon )
	cpu_flags_arm_neon? (
		cpu_flags_arm_vfp
		arm? ( cpu_flags_arm_thumb2 )
	)
	cpu_flags_arm_vfpv3? ( cpu_flags_arm_vfp )
	cpu_flags_arm_thumb2? ( cpu_flags_arm_v6 )
	cpu_flags_arm_v6? (
		arm? ( cpu_flags_arm_thumb )
	)
"
MIPS_CPU_FEATURES=( mipsdspr1:mipsdsp mipsdspr2 mipsfpu )
PPC_CPU_FEATURES=( cpu_flags_ppc_altivec:altivec cpu_flags_ppc_vsx:vsx cpu_flags_ppc_vsx2:power8 )
PPC_CPU_REQUIRED_USE="
	cpu_flags_ppc_vsx? ( cpu_flags_ppc_altivec )
	cpu_flags_ppc_vsx2? ( cpu_flags_ppc_vsx )
"
X86_CPU_FEATURES_RAW=( 3dnow:amd3dnow 3dnowext:amd3dnowext aes:aesni avx:avx avx2:avx2 fma3:fma3 fma4:fma4 mmx:mmx
					   mmxext:mmxext sse:sse sse2:sse2 sse3:sse3 ssse3:ssse3 sse4_1:sse4 sse4_2:sse42 xop:xop )
X86_CPU_FEATURES=( ${X86_CPU_FEATURES_RAW[@]/#/cpu_flags_x86_} )
X86_CPU_REQUIRED_USE="
	cpu_flags_x86_avx2? ( cpu_flags_x86_avx )
	cpu_flags_x86_fma4? ( cpu_flags_x86_avx )
	cpu_flags_x86_fma3? ( cpu_flags_x86_avx )
	cpu_flags_x86_xop?  ( cpu_flags_x86_avx )
	cpu_flags_x86_avx?  ( cpu_flags_x86_sse4_2 )
	cpu_flags_x86_aes? ( cpu_flags_x86_sse4_2 )
	cpu_flags_x86_sse4_2?  ( cpu_flags_x86_sse4_1 )
	cpu_flags_x86_sse4_1?  ( cpu_flags_x86_ssse3 )
	cpu_flags_x86_ssse3?  ( cpu_flags_x86_sse3 )
	cpu_flags_x86_sse3?  ( cpu_flags_x86_sse2 )
	cpu_flags_x86_sse2?  ( cpu_flags_x86_sse )
	cpu_flags_x86_sse?  ( cpu_flags_x86_mmxext )
	cpu_flags_x86_mmxext?  ( cpu_flags_x86_mmx )
	cpu_flags_x86_3dnowext?  ( cpu_flags_x86_3dnow )
	cpu_flags_x86_3dnow?  ( cpu_flags_x86_mmx )
"

CPU_FEATURES_MAP=(
	${ARM_CPU_FEATURES[@]}
	${MIPS_CPU_FEATURES[@]}
	${PPC_CPU_FEATURES[@]}
	${X86_CPU_FEATURES[@]}
)
IUSE="${IUSE}
	${CPU_FEATURES_MAP[@]%:*}"

CPU_REQUIRED_USE="
	${ARM_CPU_REQUIRED_USE}
	${PPC_CPU_REQUIRED_USE}
	${X86_CPU_REQUIRED_USE}
"

RDEPEND="
	>=dev-libs/fribidi-0.19.6
	>=dev-libs/gmp-6:0=
	>=media-libs/chromaprint-1.2-r1
	>=media-libs/dav1d-0.4.0:0=
	>=media-libs/fdk-aac-0.1.3:=
	>=media-libs/fontconfig-2.10.92
	>=media-libs/freetype-2.5.0.1:2
	>=media-libs/libass-0.11.0:=
	>=media-libs/libbluray-0.3.0-r1:=
	>=media-libs/libogg-1.3.0
	>=media-libs/libopenmpt-0.6.6
	>=media-libs/libvorbis-1.3.3-r1
	>=media-libs/libvpx-1.4.0:=
	>=media-libs/libwebp-0.3.0:=
	>=media-libs/opus-1.0.2-r2
	>=media-libs/svt-av1-0.9.0
	>=media-libs/x264-0.0.20130506:=
	>=media-libs/x265-1.6:=
	>=media-libs/zimg-2.7.4:=
	>=media-libs/zvbi-0.2.35
	>=media-sound/lame-3.99.5-r1
	>=net-libs/gnutls-2.12.23-r6:=
	dev-libs/libxml2:=
	x11-libs/libdrm
	amf? ( media-video/amdgpu-pro-amf:= )
	nvenc? ( media-libs/nv-codec-headers )
	opencl? ( virtual/opencl )
	qsv? ( media-libs/libvpl )
	vaapi? ( >=media-libs/libva-1.2.1-r1:0= )
	vulkan? (
		>=media-libs/vulkan-loader-1.2.189:=
		>=media-libs/libplacebo-4.192.0:=
		media-libs/shaderc
	)
"

DEPEND="${RDEPEND}
	amf? ( >=media-libs/amf-headers-1.4.28 )
"

BDEPEND="
	>=dev-build/make-3.81
	virtual/pkgconfig
	cpu_flags_x86_mmx? ( || ( >=dev-lang/nasm-2.13 >=dev-lang/yasm-1.3 ) )
	cuda? ( >=sys-devel/clang-7[llvm_targets_NVPTX] )
	test? ( net-misc/wget app-alternatives/bc )
"

REQUIRED_USE="
	cuda? ( nvenc )
	${CPU_REQUIRED_USE}"
RESTRICT="
	!test? ( test )
"

S="${WORKDIR}/${PN}-${MY_PV}"

src_prepare() {
	local patch
	for patch in debian/patches/*.patch; do
		eapply "${patch}"
	done

	default

	# -fdiagnostics-color=auto gets appended after user flags which
	# will ignore user's preference.
	sed -i -e '/check_cflags -fdiagnostics-color=auto/d' configure || die
}

src_configure() {
	local myconf=( )

	# CPU features
	for i in "${CPU_FEATURES_MAP[@]}" ; do
		use ${i%:*} || myconf+=( --disable-${i#*:} )
	done

	if use pic ; then
		myconf+=( --enable-pic )
		# disable asm code if PIC is required
		# as the provided asm decidedly is not PIC for x86.
		[[ ${ABI} == x86 ]] && myconf+=( --disable-asm )
	fi
	[[ ${ABI} == x32 ]] && myconf+=( --disable-asm ) #427004

	# Try to get cpu type based on CFLAGS.
	# Bug #172723
	# We need to do this so that features of that CPU will be better used
	# If they contain an unknown CPU it will not hurt since ffmpeg's configure
	# will just ignore it.
	for i in $(get-flag mcpu) $(get-flag march) ; do
		[[ ${i} = native ]] && i="host" # bug #273421
		myconf+=( --cpu=${i} )
		break
	done

	# LTO support, bug #566282, bug #754654, bug #772854
	[[ ${ABI} != x86 ]] && tc-is-lto && myconf+=( "--enable-lto" )
	filter-lto

	# Mandatory configuration
	myconf=(
		--enable-avfilter
		--disable-stripping
		# This is only for hardcoded cflags; those are used in configure checks that may
		# interfere with proper detections, bug #671746 and bug #645778
		# We use optflags, so that overrides them anyway.
		--disable-optimizations
		--disable-libcelt # bug #664158
		"${myconf[@]}"
	)

	# cross compile support
	if tc-is-cross-compiler ; then
		myconf+=( --enable-cross-compile --arch=$(tc-arch-kernel) --cross-prefix=${CHOST}- --host-cc="$(tc-getBUILD_CC)" )
		case ${CHOST} in
			*mingw32*)
				myconf+=( --target-os=mingw32 )
				;;
			*linux*)
				myconf+=( --target-os=linux )
				;;
		esac
	fi

	# jellyfin conf
	local JFPREFIX="${EPREFIX}/usr/lib/jellyfin-ffmpeg"
	myconf+=(
		# install prefix
		--prefix="${JFPREFIX}"
		--libdir="${JFPREFIX}/$(get_libdir)"
		--shlibdir="${JFPREFIX}/$(get_libdir)"
		--enable-rpath
		--extra-version=Jellyfin
		# disabled components
		--disable-devices
		--disable-doc
		--disable-ffplay
		--disable-ptx-compression
		--disable-autodetect
		# shlib options
		--enable-shared
		--disable-static
		$(use_enable cpudetection runtime-cpudetect)
		# licensing
		--enable-gpl
		--enable-version3
		# external libs
		--enable-gmp
		--enable-gnutls
		--enable-chromaprint
		--enable-libdrm
		--enable-libxml2
		--enable-libass
		--enable-libfreetype
		--enable-libfribidi
		--enable-libfontconfig
		--enable-libbluray
		--enable-libmp3lame
		--enable-libopus
		--enable-libtheora
		--enable-libvorbis
		--enable-libopenmpt
		--enable-libdav1d
		--enable-libsvtav1
		--enable-libwebp
		--enable-libvpx
		--enable-libx264
		--enable-libx265
		--enable-libzvbi
		--enable-libzimg
		--enable-libfdk-aac
	)
	use amf && myconf+=(
		--enable-amf
	)
	use cuda && myconf+=(
		--enable-cuda
		--enable-cuda-llvm
		--enable-cuvid
	)
	use nvenc && myconf+=(
		--enable-ffnvcodec
		--enable-nvdec
		--enable-nvenc
	)
	use opencl && myconf+=(
		--enable-opencl
	)
	use qsv && myconf+=(
		--enable-libvpl
	)
	use vaapi && myconf+=(
		--enable-vaapi
	)
	use vulkan && myconf+=(
		--enable-libshaderc
		--enable-libplacebo
		--enable-vulkan
	)

	# Use --extra-libs if needed for LIBS
	set -- "${S}/configure" \
		--cc="$(tc-getCC)" \
		--cxx="$(tc-getCXX)" \
		--ar="$(tc-getAR)" \
		--nm="$(tc-getNM)" \
		--strip="$(tc-getSTRIP)" \
		--ranlib="$(tc-getRANLIB)" \
		--pkg-config="$(tc-getPKG_CONFIG)" \
		--optflags="${CFLAGS}" \
		"${myconf[@]}" \
		${EXTRA_FFMPEG_CONF}
	echo "${@}"
	"${@}" || die
}

src_compile() {
	emake V=1
}

src_test() {
	LD_LIBRARY_PATH="${BUILD_DIR}/libpostproc:${BUILD_DIR}/libswscale:${BUILD_DIR}/libswresample:${BUILD_DIR}/libavcodec:${BUILD_DIR}/libavdevice:${BUILD_DIR}/libavfilter:${BUILD_DIR}/libavformat:${BUILD_DIR}/libavutil" \
		emake V=1 fate -k
}

src_install() {
	emake V=1 DESTDIR="${D}" install

	# remove stuff we don't actually need
	# (nothing should ever link to jellyfin-ffmpeg)
	local JFD="${D}/usr/lib/jellyfin-ffmpeg"
	rm -r "${JFD}"/{include,share} || die "Removing unneeded dirs failed"
}
