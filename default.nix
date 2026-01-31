{
  stdenv,
  lib,
  fetchFromGitHub,
}:
let
  nesasm = stdenv.mkDerivation rec {
    pname = "nesasm";
    version = "3.1";

    src = fetchFromGitHub {
      owner = "camsaul";
      repo = "nesasm";
      rev = "229033a4b76466b447ad47704808a4d03c493cee";
      hash = "sha256-56P/FFd9sehxBihQ5IdE6qipfeQOf2/37eAaT2RjFdo=";
    };

    sourceRoot = "${src.name}/source";

    makeFlags = [ "EXEDIR=." ];
    buildFlagsArray = [
      "CFLAGS=-Wno-int-conversion"
    ];

    # increase maximum length of symbols
    postPatch = ''
      substituteInPlace defs.h --replace-fail "SBOLSZ	32" 'SBOLSZ	128'
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      cp nesasm $out/bin

      runHook postInstall
    '';
  };
in
stdenv.mkDerivation {
  pname = "AccuracyCoin";
  version = "0.0.1";

  src = ./.;

  nativeBuildInputs = [
    nesasm
  ];

  buildPhase = ''
    runHook preBuild

    ${nesasm}/bin/nesasm AccuracyCoin.asm

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/
    cp AccuracyCoin.{nes,fns} $out/

    runHook postInstall
  '';

  meta = with lib; {
    description = "A large collection of NES accuracy tests on a single NROM cartridge. ";
    homepage = "https://github.com/100thCoin/AccuracyCoin";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "AccuracyCoin.nes";
  };
}
