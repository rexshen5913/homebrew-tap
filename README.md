# homebrew-tap

Homebrew tap for [rexshen5913](https://github.com/rexshen5913)'s projects.

## Usage

```bash
brew tap rexshen5913/tap
brew trust rexshen5913/tap        # Homebrew 6.0+ requires trusting third-party taps
```

> **Homebrew 6.0+ note.** Starting with Homebrew 6.0, third-party taps are
> untrusted by default. If you skip `brew trust`, installing fails with:
>
> ```text
> Error: Refusing to load cask rexshen5913/tap/raflow from untrusted tap rexshen5913/tap.
> ```
>
> Run `brew trust rexshen5913/tap` (trust the whole tap) — or
> `brew trust --cask rexshen5913/tap/raflow` (trust just this cask) — then retry.

## Available casks

| Cask | Description |
|---|---|
| [`raflow`](https://github.com/rexshen5913/raflow) | Double-tap-Cmd voice dictation with on-device Whisper correction for Chinese-English mixed speech |

```bash
brew install --cask raflow
```
