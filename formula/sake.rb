class Sake < Formula
    desc "Automate tasks with Swift"
    homepage "https://github.com/pepibumur/sake"
    version "0.1.0"
    url "https://github.com/pepibumur/sake/archive/#{version}.tar.gz"
    sha256 "xxx"
    head "https://github.com/pepibumur/sake.git"

    depends_on :xcode

    def install
        system "make", "install", "PREFIX=#{prefix}"
    end

end
