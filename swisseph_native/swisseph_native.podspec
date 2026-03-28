Pod::Spec.new do |s|
  s.name         = 'swisseph_native'
  s.version      = '0.0.1'
  s.summary      = 'Swiss Ephemeris C library compiled for Apple platforms'
  s.description  = 'Compiles the Swiss Ephemeris C source from the swisseph pub package for iOS and macOS.'
  s.homepage     = 'https://pub.dev/packages/swisseph'
  s.license      = { :type => 'AGPL-3.0' }
  s.author       = 'Astrodienst AG'

  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.14'

  s.source       = { :path => '.' }

  # Resolve C source from the swisseph pub package via .dart_tool/package_config.json.
  pkg_config = File.join(__dir__, '..', '.dart_tool', 'package_config.json')
  if File.exist?(pkg_config)
    require 'json'
    config = JSON.parse(File.read(pkg_config))
    swisseph_pkg = config['packages'].find { |p| p['name'] == 'swisseph' }
    if swisseph_pkg
      root_uri = swisseph_pkg['rootUri']
      # rootUri may be relative to .dart_tool/ or absolute file:// URI
      if root_uri.start_with?('file://')
        pkg_root = URI.decode(root_uri.sub('file://', ''))
      else
        pkg_root = File.expand_path(root_uri, File.dirname(pkg_config))
      end
      csrc = File.join(pkg_root, 'csrc')
    end
  end

  # Fallback: check common pub-cache locations.
  unless csrc && File.exist?(csrc)
    pub_cache = ENV['PUB_CACHE'] || File.expand_path('~/.pub-cache')
    candidates = Dir.glob(File.join(pub_cache, 'hosted', 'pub.dev', 'swisseph-*', 'csrc')).sort
    csrc = candidates.last
  end

  raise "Swiss Ephemeris C source not found. Run 'flutter pub get' first." unless csrc && File.exist?(csrc)

  # Copy C source into the pod's working directory during pod install.
  s.prepare_command = <<-CMD
    rm -rf csrc
    cp -R "#{csrc}" csrc
  CMD

  s.source_files         = 'csrc/**/*.{c,h}'
  s.public_header_files  = 'csrc/swephexp.h'
  s.libraries            = 'm'
  s.compiler_flags       = '-O2 -w'

  # Produce a module so the C symbols are accessible.
  s.pod_target_xcconfig  = {
    'DEFINES_MODULE' => 'YES',
    'OTHER_LDFLAGS'  => '-lm',
  }
end
