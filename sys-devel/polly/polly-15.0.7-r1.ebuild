# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..11} )
inherit cmake llvm llvm.org python-any-r1

DESCRIPTION="Polyhedral optimizations for LLVM"
HOMEPAGE="https://polly.llvm.org/"

LICENSE="Apache-2.0-with-LLVM-exceptions UoI-NCSA"
SLOT="${LLVM_MAJOR}/${LLVM_SOABI}"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc ~ppc64 ~riscv ~sparc ~x86 ~amd64-linux ~ppc-macos ~x64-macos"
IUSE="test"
RESTRICT="!test? ( test )"

DEPEND=""
RDEPEND=""
BDEPEND="
	test? (
		>=dev-util/cmake-3.16
		$(python_gen_any_dep ">=dev-python/lit-${PV}[\${PYTHON_USEDEP}]")
	)
"

LLVM_COMPONENTS=( polly cmake )
LLVM_TEST_COMPONENTS=( llvm/utils/{lit,unittest} )
llvm.org_set_globals

python_check_deps() {
	python_has_version ">=dev-python/lit-${PV}[${PYTHON_USEDEP}]"
}

pkg_pretend() {
	# Pretty sure this standalone build (for the most part)
	# doesn't depend on llvm already being installed.
	# However there may be situations (especially with major version jumps)
	# where things can go wrong.
	# I think it's better to just print a warning and have the user temporarily
	# build llvm with USE=-polly rather than having stricter deps that cause a lot
	# of circular dependencies (essentially also meaning disabling polly)
	if $(has_version ${CATEGORY}/${PN}) && ! $(has_version ${CATEGORY}/${PN}:${LLVM_MAJOR}); then
		ewarn "This is a major version upgrade!"
		ewarn "This build *may* work fine but if not unset USE=\"polly\""
		ewarn "and upgrade the rest of the LLVM toolchain first."
	fi
}

pkg_setup() {
	LLVM_MAX_SLOT=${LLVM_MAJOR} llvm_pkg_setup
	use test && python-any-r1_pkg_setup
}

src_configure() {
	# not defining LLVM_MAIN_SRC_DIR causes standalone build
	local mycmakeargs=(
		-DLLVM_POLLY_LINK_INTO_TOOLS=OFF
		-DLLVM_INCLUDE_TESTS=$(usex test)
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr/lib/llvm/${LLVM_MAJOR}"
	)
	use test && mycmakeargs+=(
		-DLLVM_BUILD_TESTS=ON
		-DLLVM_EXTERNAL_LIT="${EPREFIX}/usr/bin/lit"
		-DLLVM_LIT_ARGS="$(get_lit_flags)"
		-DPython3_EXECUTABLE="${PYTHON}"
	)
	cmake_src_configure
}

src_test() {
	local -x LIT_PRESERVES_TMP=1
	cmake_build check-polly
}

pkg_postinst() {
	# print a warning if building independent from sys-devel/llvm
	if ! $(has_version sys-devel/llvm:${LLVM_MAJOR}[polly]); then
		elog "sys-devel/llvm:${LLVM_MAJOR}[polly] wasn't found on the system!"
		elog "If USE=\"polly\" isn't set you need to manually load polly as"
		elog "a clang extension by adding the following flags:"
		elog "     \"-Xclang -load -Xclang LLVMPolly.so\""
		elog "Then the usual \"-mllvm -polly\" should work."
	fi
}
