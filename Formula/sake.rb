class Sake < Formula
  desc "Automate tasks with Swift"
  homepage "https://github.com/xcodeswift/sake"
  version "0.3.0"
  url "https://github.com/xcodeswift/sake/archive/#{version}.tar.gz"
  sha256 "3a118a91fbe8453d9c8278b20e09bb39b4f395ca05418391369fa91819352181"
  head "https://github.com/xcodeswift/sake.git"

  depends_on :xcode

  def install
    sake_path = "#{buildpath}/.build/release/sake"
    ohai "Building Sake"
    libraryPathSwiftContent = [
      "import Foundation",
      "var librariesPath: String? = \"#{lib}\""
    ].join("\n") + "\n"
    File.write("#{buildpath}/Sources/SakeKit/LibraryPath.swift", libraryPathSwiftContent)
    system("swift build --disable-sandbox -c release")
    bin.install sake_path
    ohai "Installing libraries"
    lib.install "#{buildpath}/.build/release/libSakefileDescription.dylib"
    lib.install "#{buildpath}/.build/release/SakefileDescription.swiftdoc"
    lib.install "#{buildpath}/.build/release/SakefileDescription.swiftmodule"
  end

end
