class Stubby < Formula
  desc "DNS privacy enabled stub resolver service based on getdns"
  homepage "https://getdnsapi.net/blog/dns-privacy-daemon-stubby/"
  url "https://github.com/getdnsapi/stubby/archive/v0.1.0.tar.gz"
  sha256 "6210291850d6f7f124a5ba4bcee2f50814f020b7a0c4e67c6646bfe35ed5dd5b"
  head "https://github.com/getdnsapi/stubby.git", :branch => "master"

  link_overwrite "bin/stubby"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "getdns" => :build
  depends_on "libtool" => :build

  def install
    system "autoreconf", "-fiv"
    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules"
    system "make", "install"
  end

  plist_options :startup => true, :manual => "sudo stubby -C #{HOMEBREW_PREFIX}/etc/stubby/stubby.conf"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-/Apple/DTD PLIST 1.0/EN" "http:/www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>KeepAlive</key>
        <true/>
        <key>RunAtLoad</key>
        <true/>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/stubby</string>
          <string>-C</string>
          <string>#{etc}/stubby/stubby.conf</string>
        </array>
        <key>StandardErrorPath</key>
        <string>#{var}/log/stubby/stubby.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/stubby/stubby.log</string>
      </dict>
    </plist>
    EOS
  end

  test do
    (testpath/"test_message.txt").write("getdnsapi.net")
    output = shell_output("#{bin}/stubby -C #{etc}/stubby.conf -z 127.0.0.1:5553 -e 0 -F test_message.txt -n 2>/dev/null")
    assert_match "Response code was: GOOD", output
  end
end