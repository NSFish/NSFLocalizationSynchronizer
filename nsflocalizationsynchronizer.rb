class Nsflocalizationsynchronizer < Formula
  desc ".strings文件和Excel语言包之间的双向同步工具"
  homepage "https://github.com/NSFish/NSFLocalizationSynchronizer"
  url "https://github.com/NSFish/NSFLocalizationSynchronizer/releases/download/1.0/NSFLocalizationSynchronizerCLI"
  sha256 "614f059c1e3b874061805b6299880bcbde0fed5dcf8906e9d71af8a6e7645381"

  def install
    bin.install "NSFLocalizationSynchronizerCLI"
  end
end
