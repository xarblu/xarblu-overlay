# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV="$(ver_cut 1-3)-$(ver_cut 4)"

inherit flag-o-matic toolchain-funcs

DESCRIPTION="FFmpeg for Jellyfin"
HOMEPAGE="https://github.com/jellyfin/jellyfin-ffmpeg"

if [[ "${PV}" == *_pre* ]]; then
	COMMIT="c754fb67b0cc544f0a5d35ef572dbf12c527688a"
	SRC_URI="
		https://github.com/jellyfin/jellyfin-ffmpeg/archive/${COMMIT}.tar.gz
			-> ${PN}-${COMMIT::8}.tar.gz
	"
	S="${WORKDIR}/${PN}-${COMMIT}"
else
	SRC_URI="
		https://github.com/jellyfin/jellyfin-ffmpeg/archive/v${MY_PV}.tar.gz
			-> ${P}.tar.gz
	"
	S="${WORKDIR}/${PN}-${MY_PV}"
	KEYWORDS="~amd64 ~arm64"
fi

SLOT="0"
LICENSE="GPL-3"

# only make hwaccel sulutions optional
IUSE="amf cpudetection nvenc opencl +pic qsv test vaapi vulkan"

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
	cpu_flags_arm_asimddp:dotprod
	cpu_flags_arm_i8mm:i8mm
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
	>=app-arch/xz-utils-5.0.5-r1
	>=dev-libs/fribidi-0.19.6
	>=dev-libs/gmp-6:0=
	>=dev-libs/openssl-1.0.1h-r2:0=
	>=media-libs/chromaprint-1.2-r1
	>=media-libs/dav1d-0.5.0:0=
	>=media-libs/fdk-aac-0.1.3:=
	>=media-libs/fontconfig-2.10.92
	>=media-libs/freetype-2.5.0.1:2
	>=media-libs/libass-0.11.0:=
	>=media-libs/libbluray-0.3.0-r1:=
	>=media-libs/libogg-1.3.0
	>=media-libs/libopenmpt-0.6.6
	>=media-libs/libtheora-1.1.1[encode]
	>=media-libs/libvorbis-1.3.3-r1
	>=media-libs/libvpx-1.4.0:=
	>=media-libs/libwebp-0.3.0:=
	>=media-libs/opus-1.0.2-r2
	>=media-libs/svt-av1-0.9.0:=
	>=media-libs/x264-0.0.20130506:=
	>=media-libs/x265-1.6:=
	>=media-libs/zimg-2.7.4:=
	>=media-libs/zvbi-0.2.35
	>=media-sound/lame-3.99.5-r1
	>=net-libs/srt-1.3.0:=
	>=sys-libs/zlib-1.2.8-r1
	>=virtual/libiconv-0-r1
	dev-libs/libxml2:=
	media-libs/harfbuzz:=
	amf? ( media-video/amdgpu-pro-amf:= )
	nvenc? ( >=media-libs/nv-codec-headers-11.1.5.3 )
	opencl? ( virtual/opencl )
	qsv? ( media-libs/libvpl )
	vaapi? (
		>=media-libs/libva-1.2.1-r1:0=
		x11-libs/libdrm
	)
	vulkan? (
		>=media-libs/vulkan-loader-1.3.277:=
		>=media-libs/libplacebo-4.192.0:=
		media-libs/shaderc
	)
"

DEPEND="${RDEPEND}
	amf? ( >=media-libs/amf-headers-1.4.28 )
	vulkan? ( >=dev-util/vulkan-headers-1.3.277 )
"

BDEPEND="
	>=dev-build/make-3.81
	virtual/pkgconfig
	cpu_flags_x86_mmx? ( || ( >=dev-lang/nasm-2.13 >=dev-lang/yasm-1.3 ) )
	nvenc? ( >=sys-devel/clang-7[llvm_targets_NVPTX] )
	test? ( net-misc/wget app-alternatives/bc )
"

REQUIRED_USE="
	!amd64? ( !amf !nvenc !qsv !vaapi )
	${CPU_REQUIRED_USE}"
RESTRICT="
	!test? ( test )
"

src_prepare() {
	# Jellyfin patches
	eapply debian/patches/

	default

	# -fdiagnostics-color=auto gets appended after user flags which
	# will ignore user's preference.
	sed -i -e '/check_cflags -fdiagnostics-color=auto/d' configure || die
	# We need to detect LTO usage before multilib stuff and filter-lto is called (bug #923491)
	if tc-is-lto ; then
		# Respect -flto value, e.g -flto=thin
		local v="$(get-flag flto)"
		[[ ${v} != -flto ]] && LTO_FLAG="--enable-lto=${v}" || LTO_FLAG="--enable-lto"
	fi
	filter-lto
}

src_configure() {
	local myconf=( )

	# bug 842201
	use ia64 && tc-is-gcc && append-flags \
		-fno-tree-ccp \
		-fno-tree-dominator-opts \
		-fno-tree-fre \
		-fno-code-hoisting \
		-fno-tree-pre \
		-fno-tree-vrp

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
	if [[ ${ABI} != x86 && ! -z ${LTO_FLAG} ]]; then
		myconf+=( ${LTO_FLAG} )
	fi

	# Mandatory configuration
	myconf=(
		--disable-libaribcaption # libaribcaption is not packaged (yet?)
		--disable-libxeve
		--disable-libxevd
		--disable-d3d12va
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

	# Custom Gentoo Jellyfin flags
	myconf+=(
		--disable-autodetect
		--disable-devices
		--enable-rpath
		--extra-version=Jellyfin
		$(use_enable cpudetection runtime-cpudetect)
	)

	# emulate builder/build.sh linux64{,arm} gpl-shared
	# builder/variants/defaults-gpl.sh
	myconf+=(
		--enable-gpl
		--enable-version3
		--disable-ffplay
		--disable-debug
		--disable-doc
		--disable-ptx-compression
		--disable-sdl2
		--disable-libxcb
		--disable-xlib
	)
	# builder/variants/defaults-gpl-shared.sh
	myconf+=(
		--enable-shared
		--disable-static
	)
	# builder/scripts.d/*.sh
	myconf+=(
		--enable-iconv
		--enable-zlib
		--enable-libfreetype
		--enable-libfribidi
		--enable-gmp
		--enable-libxml2
		--enable-openssl
		--enable-lzma
		--enable-fontconfig
		--enable-libharfbuzz
		--enable-libvorbis
		$(use_enable opencl)
		$(use_enable amf)
		--enable-chromaprint
		--enable-libdav1d
		--disable-dxva2
		--disable-d3d11va
		--disable-d3d12va
		--enable-libfdk-aac
		$(use_enable nvenc ffnvcodec)
		$(use_enable nvenc cuda)
		$(use_enable nvenc cuda-llvm)
		$(use_enable nvenc cuvid)
		$(use_enable nvenc nvdec)
		$(use_enable nvenc nvenc)
		--enable-libass
		--enable-libbluray
		--enable-libmp3lame
		--enable-libopus
		--enable-libtheora
		$(use_enable qsv libvpl)
		--enable-libvpx
		--enable-libwebp
		--enable-libopenmpt
		--enable-libsrt
		--enable-libsvtav1
		--enable-libx264
		--enable-libx265
		--enable-libzimg
		--enable-libzvbi
	)

	# builder/scripts.d/50-vaapi/*.sh
	myconf+=(
		$(use_enable vaapi libdrm)
		$(use_enable vaapi)
	)

	# builder/scripts.d/50-vulkan/*.sh
	myconf+=(
		$(use_enable vulkan)
		$(use_enable vulkan libshaderc)
		$(use_enable vulkan libplacebo)
	)

	# Use --extra-libs if needed for LIBS
	set -- "${S}/configure" \
		--prefix="${EPREFIX}/usr/lib/jellyfin-ffmpeg" \
		--libdir="${EPREFIX}/usr/lib/jellyfin-ffmpeg/$(get_libdir)" \
		--shlibdir="${EPREFIX}/usr/lib/jellyfin-ffmpeg/$(get_libdir)" \
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
}
