# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..11} )
inherit cmake llvm llvm.org python-any-r1

DESCRIPTION="Polyhedral optimizations for LLVM"
HOMEPAGE="https://polly.llvm.org/"

LICENSE="Apache-2.0-with-LLVM-exceptions UoI-NCSA"
SLOT="${LLVM_MAJOR}/${LLVM_SOABI}"
KEYWORDS="~loong"
IUSE="test"
RESTRICT="!test? ( test )"

# upstream says to build against the exact same version
# but just depending on LLVM_MAJOR should be fine since we build
# a shared library + this avoids circular dependencies unless it's
# a major version upgrade
DEPEND="
	sys-devel/llvm:${LLVM_MAJOR}=
"
RDEPEND="${DEPENDS}"
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
