class Sake < Formula
  desc "Automate tasks with Swift"
  homepage "https://github.com/xcodeswift/sake"
  url "https://github.com/xcodeswift/sake/archive/0.4.0.tar.gz"
  sha256 "06eba536e46758f64191f650cf7df4b7d33bc6aea9e822ab2668885ed50a3b3b"
  head "https://github.com/xcodeswift/sake.git"

  depends_on :xcode => "9.2"

  def install
    sake_path = "#{buildpath}/.build/release/sake"
    ohai "Building Sake"
    library_path_swift_content = [
      "import Foundation",
      "var librariesPath: String? = \"#{include}\"",
    ].join("\n") + "\n"
    File.write("#{buildpath}/Sources/SakeKit/LibraryPath.swift", library_path_swift_content)
    system("swift build --disable-sandbox -c release")
    bin.install sake_path
    ohai "Installing libraries"
    include.install "#{buildpath}/.build/release/libSakefileDescription.dylib"
    include.install "#{buildpath}/.build/release/SakefileDescription.swiftdoc"
    include.install "#{buildpath}/.build/release/SakefileDescription.swiftmodule"
  end

  test do
    system "#{bin}/sake", "init"
    system "#{bin}/sake", "tasks"
    system "#{bin}/sake", "task", "build"
  end
end
