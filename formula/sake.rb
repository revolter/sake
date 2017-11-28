class Sake < Formula
  desc "Automate tasks with Swift"
  homepage "https://github.com/pepibumur/sake"
  version "0.1.0"
  url "https://github.com/pepibumur/sake/archive/#{version}.tar.gz"
  sha256 "6f97773b9cdffe633aff4c8c51302c8f495280d490a6fbb68af9bf8d18fec5c0"
  head "https://github.com/pepibumur/sake.git"

  depends_on :xcode

  def install
    sake_path = "#{buildpath}/.build/release/sake"
    ohai "Building Sake"
    libraryPathSwiftContent = "import Foundation\n\nvar libraryPath: String? = \"#{lib}\""
    File.write("#{buildpath}/Sources/SakeKit/LibraryPath.swift", libraryPathSwiftContent)
    system("swift build --disable-sandbox -c release -Xswiftc -static-stdlib")
    bin.install sake_path
    ohai "Installing libraries"
    lib.install "#{buildpath}/.build/release/libSakefileDescription.dylib"
    lib.install "#{buildpath}/.build/release/SakefileDescription.swiftdoc"
    lib.install "#{buildpath}/.build/release/SakefileDescription.swiftmodule"
  end

end
