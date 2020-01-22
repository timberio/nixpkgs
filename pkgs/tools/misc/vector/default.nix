{ stdenv, lib, fetchFromGitHub, rustPlatform
, openssl, pkgconfig, protobuf
, Security, libiconv, rdkafka, cmake
, tzdata

, features ?
    (if stdenv.isAarch64
     then [ "shiplift/unix-socket" "jemallocator" "rdkafka" "rdkafka/dynamic_linking" ]
     else [ "leveldb" "leveldb/leveldb-sys-2" "shiplift/unix-socket" "jemallocator" "rdkafka" "rdkafka/dynamic_linking" ])
}:

rustPlatform.buildRustPackage rec {
  pname = "vector";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner  = "timberio";
    repo   = pname;
    rev    = "refs/tags/v${version}";
    sha256 = "0w1gkdl57la6adkql9ym36xsr395qnm9jbjgiqhcblvbrpysc35z";
  };


  cargoSha256 = "01hynn8ccpwqrirr1bczqc7q7pqkzfjks2v6q4f32xbm50b31fky";
  buildInputs = [ openssl pkgconfig protobuf rdkafka cmake ]
                ++ stdenv.lib.optional stdenv.isDarwin [ Security libiconv ];

  # needed for internal protobuf c wrapper library
  PROTOC="${protobuf}/bin/protoc";
  PROTOC_INCLUDE="${protobuf}/include";

  cargoBuildFlags = [ "--no-default-features" "--features" "${lib.concatStringsSep "," features}" ];
  checkPhase = "TZDIR=${tzdata}/share/zoneinfo cargo test --no-default-features --features ${lib.concatStringsSep "," features} -- --skip parses_sink_full_es_aws";

  meta = with stdenv.lib; {
    description = "A high-performance logs, metrics, and events router";
    homepage    = "https://github.com/timberio/vector";
    license     = with licenses; [ asl20 ];
    maintainers = with maintainers; [ thoughtpolice ];
    platforms   = platforms.all;
  };
}
