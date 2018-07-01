{ mkDerivation, base, config-value, containers, directory, gi-gtk
, gtk3, microlens, mtl, optparse-applicative, stdenv, taffybar
, text, transformers, X11, xmonad, xmonad-contrib
}:
mkDerivation {
  pname = "xalternative";
  version = "0.1";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base config-value containers directory microlens taffybar text
    transformers X11 xmonad xmonad-contrib
  ];
  executableHaskellDepends = [
    base gi-gtk gtk3 mtl optparse-applicative taffybar text
    transformers
  ];
  homepage = "https://github.com/thumphries/xalternative";
  description = "XMonad+";
  license = stdenv.lib.licenses.bsd3;
}
