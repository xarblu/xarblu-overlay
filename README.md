# xarblu-overlay
This is my personal overlay of Gentoo GNU/Linux ebuilds.

If you want to add them for whatever reason use `app-eselect/eselect-repository`

`# eselect repository add xarblu-overlay git https://github.com/xarblu/xarblu-overlay.git`

There also is a modified mercurial.eclass here which only checks out the requested
commit instead of cloning the entire commit history into the build directory (useful if using the firefox-nightly ebuild)

To enable it add `eclass-override = gentoo xarblu-overlay` (where the rightmost entry is preferred) under a section called `[DEFAULT]` (for all repos)
or under `[xarblu-overly]`(just for this repo) in your `/etc/portage/repos.conf`.
