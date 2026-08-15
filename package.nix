{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  source = import ./version.nix;
in
stdenvNoCC.mkDerivation {
  pname = "moshi-hook";
  inherit (source) version;

  src = fetchurl {
    url = "https://cdn.getmoshi.app/hook/v${source.version}/moshi-hook_Linux_x86_64.tar.gz";
    inherit (source) hash;
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm755 moshi-hook "$out/bin/moshi-hook"
    ln -s moshi-hook "$out/bin/moshi"

    runHook postInstall
  '';

  meta = {
    description = "Host integration daemon and CLI for Moshi";
    homepage = "https://getmoshi.app";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "moshi-hook";
  };
}
