# Flake Demo

``` sh
$ nix develop .#unstable -c bb --version`
babashka v0.7.5
```

``` sh
$ nix develop .#release -c bb --version`
babashka v0.7.3
```

``` sh
$ nix develop .#custom -c bb --version`
babashka v0.7.2
```

Enter shell environment with `nix develop .#unstable`

Alternatively `nix shell .#devEnv.x86_64-linux`
