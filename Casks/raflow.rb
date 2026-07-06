cask "raflow" do
  version "0.1.0"
  sha256 "bb6603f2998762efd452041e03a2cfda2ce081c7e7b474d621b22bf58275c230"

  url "https://github.com/rexshen5913/raflow/releases/download/v#{version}/raflow-v#{version}-macos.zip"
  name "raflow"
  desc "Double-tap-Cmd voice dictation with on-device Whisper correction for Chinese-English mixed speech"
  homepage "https://github.com/rexshen5913/raflow"

  depends_on arch: :arm64
  depends_on macos: :ventura

  app "raflow.app"

  # raflow needs the Whisper model (~547 MB) and a small Silero VAD model in
  # ~/Library/Application Support/raflow/models. Download them on install (if
  # missing), verifying SHA-256 so a corrupted or tampered upstream can't feed
  # bad model data to whisper.cpp.
  postflight do
    require "fileutils"
    require "digest"
    models = File.join(Dir.home, "Library", "Application Support", "raflow", "models")
    FileUtils.mkdir_p(models)
    [
      ["ggml-large-v3-turbo-q5_0.bin",
       "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo-q5_0.bin",
       "394221709cd5ad1f40c46e6031ca61bce88931e6e088c188294c6d5a55ffa7e2"],
      ["ggml-silero-v6.2.0.bin",
       "https://huggingface.co/ggml-org/whisper-vad/resolve/main/ggml-silero-v6.2.0.bin",
       "2aa269b785eeb53a82983a20501ddf7c1d9c48e33ab63a41391ac6c9f7fb6987"],
    ].each do |name, file_url, want_sha|
      dest = File.join(models, name)
      next if File.exist?(dest)

      tmp = "#{dest}.download"
      opoo "Downloading raflow model #{name} (first install only)…"
      system_command "/usr/bin/curl",
                     args: ["-L", "--fail", "--progress-bar", "-o", tmp, file_url]
      got_sha = Digest::SHA256.file(tmp).hexdigest
      if got_sha != want_sha
        File.delete(tmp)
        odie "raflow model #{name} failed checksum (expected #{want_sha}, got #{got_sha})"
      end
      FileUtils.mv(tmp, dest)
    end

    # The app is self-signed (open source, runs fully on-device) but not Apple
    # notarized, so strip the download quarantine to avoid a Gatekeeper block.
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/raflow.app"]
  end

  uninstall quit: "dev.raflow.raflow"

  caveats <<~EOS
    raflow runs entirely on-device; audio never leaves your Mac.

    On first launch, grant these permissions in System Settings:
      - Speech Recognition and Microphone (prompted automatically)
      - Input Monitoring (double-tap Cmd detection)
      - Accessibility (typing text into the focused field)

    Start/stop dictation by double-tapping the Cmd key.

    Custom vocabulary: ~/Library/Application Support/raflow/contextual_terms.txt
    Corrections:       ~/Library/Application Support/raflow/replacements.txt

    Models are stored in ~/Library/Application Support/raflow/models and are
    NOT removed on uninstall.
  EOS
end
