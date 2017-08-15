platform :osx, '10.10'
# ignore all warnings from all pods
inhibit_all_warnings!

workspace 'NSFLocalizationSynchronizer'

def pods
      pod 'ReactiveObjC'
      pod 'XlsxReaderWriter', :git=>'https://github.com/NSFish/XlsxReaderWriter.git', :branch => 'master'

end

target 'NSFLocalizationSynchronizer' do
  project 'App/NSFLocalizationSynchronizer.xcodeproj'
  
  pods
end

target 'NSFLocalizationSynchronizerCLI' do
  project 'Command Line/NSFLocalizationSynchronizerCLI.xcodeproj'
  
  pods
end
