{
  packages,
}:
final: _prev: {
  pi-agent-nvim = packages.${final.stdenv.hostPlatform.system} or { };
}
