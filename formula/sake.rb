class Sake < Formula
  desc "Automate tasks with Swift"
  homepage "https://github.com/pepibumur/sake"
  version "0.1.0"
  url "https://github.com/pepibumur/sake/archive/#{version}.tar.gz"
  sha256 "69b1f0595e50e0e2027ca2bad3d782cfe1dc4719670aec89961ab81c16f06755"
  head "https://github.com/pepibumur/sake.git"

  depends_on :xcode

  def install
    sake_path = "#{buildpath}/.build/release/sake"
    ohai "Building Sake"
    system("swift package clean")
    libraryPathSwiftContent = "import Foundation\n\nvar library: String? = \"lib\""
    File.write("#{buildpath}/Sources/SakeKit/LibraryPath.swift", libraryPathSwiftContent)
    system("swift build --disable-sandbox -c release -Xswiftc -static-stdlib")
    bin.install sake_path
    ohai "Installing libraries"
    lib.install "#{buildpath}/.build/release/libSakefileDescription.dylib"
    lib.install "#{buildpath}/.build/release/SakefileDescription.swiftdoc"
    lib.install "#{buildpath}/.build/release/SakefileDescription.swiftmodule"
  end

end
