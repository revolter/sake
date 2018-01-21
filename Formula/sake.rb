class Sake < Formula
  desc "Automate tasks with Swift"
  homepage "https://github.com/xcodeswift/sake"
  version "https://github.com/xcodeswift/sake/archive/0.6.0.tar.gz"
  sha256 "c7f6dad971877750b66f7ee4174a669d9656fc039bce9d2d3fb97735c03049c8"
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
    include.install "#{buildpath}/.build/release/SwiftShell.swiftdoc"
    include.install "#{buildpath}/.build/release/SwiftShell.swiftmodule"
  end

  test do
    system "#{bin}/sake", "init"
    system "#{bin}/sake", "tasks"
    system "#{bin}/sake", "task", "build"
  end
end
