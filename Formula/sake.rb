class Sake < Formula
  desc "Automate tasks with Swift"
  homepage "https://github.com/xcodeswift/sake"
  version "https://github.com/xcodeswift/sake/archive/0.6.0.tar.gz"
  sha256 "c7f6dad971877750b66f7ee4174a669d9656fc039bce9d2d3fb97735c03049c8"
  head "https://github.com/xcodeswift/sake.git"

  depends_on :xcode => "9.2"

  def install
    system("#{buildpath}/scripts/build #{buildpath.to_s} #{include.to_s}")
    build_data = File.readlines("#{buildpath}/build.data")
    binary = build_data.select{ |f| f.include?("binary:") }.map{ |f| f.gsub("binary: ", "")}.first
    libraries = build_data.select{ |f| f.include?("library:") }.map{ |f| f.gsub("library: ", "")}
    bin.install "#{buildpath}/#{binary}"
    libraries.each do |library_path|
      include.install "#{buildpath}/#{library_path}"
    end
  end

  test do
    system "#{bin}/sake", "init"
    system "#{bin}/sake", "tasks"
    system "#{bin}/sake", "task", "build"
  end
end
