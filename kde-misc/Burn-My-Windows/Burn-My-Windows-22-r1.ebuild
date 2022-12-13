# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Disintegrate your windows with style"
HOMEPAGE="https://github.com/Schneegans/Burn-My-Windows"
SRC_URI="https://github.com/Schneegans/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	kde-plasma/kwin:5=
	kde-frameworks/kwidgetsaddons:5=[designer]
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-lang/perl
"
# Allow choosing of the wanted effects
EFFECTS="doom energize-a energize-b fire glide hexagon incinerate pixelate pixel-wheel pixel-wipe tv wisps"
IUSE="${EFFECTS}"
REQUIRED_USE="|| ( ${EFFECTS} )"

# We only care for the kwin effects here
S="${WORKDIR}/${P}/kwin"
BUILD_DIR="${WORKDIR}/${P}_build"

# modded generate() from kwin/build.sh to allow USE flags and skip unneeded steps
# This method is called one for each effect. The parameters are as follows:
# $1: The nick of the effect (e.g. "energize-a")
# $2: The name of the effect (e.g. "Energize A")
# $3: A short description of the effect (e.g. "Beam your windows away")
generate() {
	# We use the nick for the effect's directory name by replacing dashes with underscoares.
	DIR_NAME="kwin4_effect_$(echo "$1" | tr '-' '_')"

	# We transform the nick to CamelCase for the JavaScript class name.
	EFFECT_CLASS="BurnMyWindows$(sed -r 's/(^|-)(\w)/\U\2/g' <<<"$1")Effect"

	# Now create all required resource directories.
	mkdir -p "$BUILD_DIR/$DIR_NAME/contents/shaders"
	mkdir -p "$BUILD_DIR/$DIR_NAME/contents/code"
	mkdir -p "$BUILD_DIR/$DIR_NAME/contents/config"
	mkdir -p "$BUILD_DIR/$DIR_NAME/contents/ui"

	# Copy the config file if it exists.
	if [ -f "$1/main.xml" ]; then
	  cp "$1/main.xml" "$BUILD_DIR/$DIR_NAME/contents/config"
	fi

	# Copy the ui file if it exists.
	if [ -f "$1/config.ui" ]; then
	  cp "$1/config.ui" "$BUILD_DIR/$DIR_NAME/contents/ui"
	fi

	# Now we create the effect's JavaScript source file. This is done by taking main.js.in
	# and replacing some placeholders with effect-specific files and values.
	ON_SETTINGS_CHANGE=""
	ON_ANIMATION_BEGIN=""

	# If the effect's directory contains a onSettingsChanged.js, we replace the
	# corresponding placeholder with it's content. We replace all occurences of / temporily
	# so that the REGEX works.
	if [ -f "$1/onSettingsChanged.js" ]; then
	  ON_SETTINGS_CHANGE=$(tr '/' '\f' < "$1/onSettingsChanged.js")
	fi

	# Similarily, we will inject the contents of onAnimationBegin.js.
	if [ -f "$1/onAnimationBegin.js" ]; then
	  ON_ANIMATION_BEGIN=$(tr '/' '\f' < "$1/onAnimationBegin.js")
	fi

	cp main.js.in "$BUILD_DIR/$DIR_NAME/contents/code/main.js"
	perl -pi -e "s/%ON_SETTINGS_CHANGE%/$ON_SETTINGS_CHANGE/g;" "$BUILD_DIR/$DIR_NAME/contents/code/main.js"
	perl -pi -e "s/%ON_ANIMATION_BEGIN%/$ON_ANIMATION_BEGIN/g;" "$BUILD_DIR/$DIR_NAME/contents/code/main.js"
	perl -pi -e "s/%EFFECT_CLASS%/$EFFECT_CLASS/g;"             "$BUILD_DIR/$DIR_NAME/contents/code/main.js"
	perl -pi -e "s/%SHADER_NAME%/$1/g;"                         "$BUILD_DIR/$DIR_NAME/contents/code/main.js"
	perl -pi -e "s/\f/\//g;"                                    "$BUILD_DIR/$DIR_NAME/contents/code/main.js"

	# Now create the metadata.json file. Again, we replace some placeholders.
	cp metadata.json.in "$BUILD_DIR/$DIR_NAME/metadata.json"
	perl -pi -e "s/%ICON%/$1/g;"            "$BUILD_DIR/$DIR_NAME/metadata.json"
	perl -pi -e "s/%NAME%/$2/g;"            "$BUILD_DIR/$DIR_NAME/metadata.json"
	perl -pi -e "s/%DESCRIPTION%/$3/g;"     "$BUILD_DIR/$DIR_NAME/metadata.json"
	perl -pi -e "s/%DIR_NAME%/$DIR_NAME/g;" "$BUILD_DIR/$DIR_NAME/metadata.json"

	# Now create the two required shader files. We prepend the common.glsl to each shader.
	# We also define KWIN and KWIN_LEGACY. The code in common.glsl takes some different
	# paths based on these defines.
	{
	  echo "#version 140"
	  echo "#define KWIN"
	  echo ""
	  echo "// This file is automatically generated during the build process."
	  echo ""
	  cat "../resources/shaders/common.glsl"
	  cat "../resources/shaders/$1.frag"
	} > "$BUILD_DIR/$DIR_NAME/contents/shaders/$1_core.frag"

	{
	  echo "#define KWIN_LEGACY"
	  echo ""
	  echo "// This file is automatically generated during the build process."
	  echo ""
	  cat "../resources/shaders/common.glsl"
	  cat "../resources/shaders/$1.frag"
	} > "$BUILD_DIR/$DIR_NAME/contents/shaders/$1.frag"
}

src_compile() {
	if use doom; then generate "doom" "Doom [Burn-My-Windows]" "Melt your windows"; fi
	if use energize-a; then generate "energize-a" "Energize A [Burn-My-Windows]" "Beam your windows away"; fi
	if use energize-b; then generate "energize-b" "Energize B [Burn-My-Windows]" "Using different transporter technology results in an alternative visual effect"; fi
	if use fire; then generate "fire" "Fire [Burn-My-Windows]" "The classic effect inspired by Compiz"; fi
	if use glide; then generate "glide" "Glide [Burn-My-Windows]" "Fade the window to transparency with subtle 3D effects"; fi
	if use hexagon; then generate "hexagon" "Hexagon [Burn-My-Windows]" "With glowing lines and hexagon-shaped tiles, this effect looks very sci-fi"; fi
	if use incinerate; then generate "incinerate" "Incinerate [Burn-My-Windows]"  "A less snappy but definitely more fancy take on the fire effect"; fi
	if use pixelate; then generate "pixelate" "Pixelate [Burn-My-Windows]" "Pixelate the window and randomly hide the pixels"; fi
	if use pixel-wheel; then generate "pixel-wheel" "Pixel Wheel [Burn-My-Windows]" "Pixelate the window and hide the pixels in a wheel-like fashion"; fi
	if use pixel-wipe; then generate "pixel-wipe" "Pixel Wipe [Burn-My-Windows]" "Pixelate the window and hide the pixels radially, starting from the pointer position"; fi
	if use tv; then generate "tv" "TV Effect [Burn-My-Windows]" "Make windows close like turning off a TV"; fi
	if use wisps; then generate "wisps" "Wisps [Burn-My-Windows]" "Let your windows be carried away to the realm of dreams by these little fairies"; fi
}

src_install() {
	insinto /usr/share/kwin/effects/
	for effect in "${BUILD_DIR}/kwin4_effect_"*; do
		doins -r ${effect}
	done
}