**RPMCreator** - GUI for building RPM and DEB packages from pre-installed files and folders.

**Dependencies:** `xterm rpm-build dpkg-dev gtk2`

Rpmbuild is using. Building an RPM package goes through the creation of a simple project that can be saved/loaded, which allows you to make the build process step-by-step. Working directory: `~/rpmbuild`. Starting from version `1.6-0`, you can create DEB packages in `~/debbuild`.

![](https://github.com/AKotov-dev/RPMCreator/blob/main/ScreenShot6.png)

**Note:** Icons of `*.prj` files in Mageia distributions may not be displayed by default. The strict binding of the Mageia distribution to the `Adwaita` icon theme during the assembly of all file managers is the **reason for the incorrect display of mime-type icons**. To fix this problem, install [adwaita-mime-patch ](https://github.com/AKotov-dev/adwaita-mime-patch) for its version of Mageia.
