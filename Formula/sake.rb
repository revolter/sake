class Sake < Formula
  desc "Automate tasks with Swift"
  homepage "https://github.com/pepibumur/sake"
  version "0.1.0"
  url "https://github.com/pepibumur/sake/archive/#{version}.tar.gz"
  sha256 "4d7fca39addffe79d978132ee98c758736477ae27957f00b52cdc514f8c91c2b"
  head "https://github.com/pepibumur/sake.git"

  depends_on :xcode

  def install
    sake_path = "#{buildpath}/.build/release/sake"
    ohai "Building Sake"
    libraryPathSwiftContent = [
      "import Foundation",
      "var librariesPath: String = \"#{lib}\""
    ].join("\n") + "\n"
    File.write("#{buildpath}/Sources/SakeKit/LibraryPath.swift", libraryPathSwiftContent)
    system("swift build --disable-sandbox -c release")
    bin.install sake_path
    ohai "Installing libraries"
    lib.install "#{buildpath}/.build/release/libSakefileDescription.dylib"
    lib.install "#{buildpath}/.build/release/SakefileDescription.swiftdoc"
    lib.install "#{buildpath}/.build/release/SakefileDescription.swiftmodule"
    lib.install "#{buildpath}/.build/release/libSakefileUtils.dylib"
    lib.install "#{buildpath}/.build/release/SakefileUtils.swiftdoc"
    lib.install "#{buildpath}/.build/release/SakefileUtils.swiftmodule"
  end

end
