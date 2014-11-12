# Installs VirtualBox
#
# Usage:
#
#   include virtualbox
#
# http://download.virtualbox.org/virtualbox/4.3.18/VirtualBox-4.3.18-96516-OSX.dmg
# http://download.virtualbox.org/virtualbox/4.3.18/Oracle_VM_VirtualBox_Extension_Pack-4.3.18-96516.vbox-extpack

class virtualbox {

  exec { 'Kill Virtual Box Processes':
    command     => 'pkill "VBoxXPCOMIPCD" || true && pkill "VBoxSVC" || true && pkill "VBoxHeadless" || true',
    path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    refreshonly => true,
  }

  package { 'VirtualBox-4.3.18':
    ensure   => installed,
    provider => 'pkgdmg',
    source   => 'http://download.virtualbox.org/virtualbox/4.3.18/VirtualBox-4.3.18-96516-OSX.dmg',
    require  => Exec['Kill Virtual Box Processes']
  }
}

class virtualbox::extensions {
  virtualbox::extension { 'extpack':
    source   => 'http://download.virtualbox.org/virtualbox/4.3.18/Oracle_VM_VirtualBox_Extension_Pack-4.3.18-96516.vbox-extpack',
    creates  => '/Applications/VirtualBox.app/Contents/MacOS/ExtensionPacks/Oracle_VM_VirtualBox_Extension_Pack/ExtPack.xml',
    require  => Package['VirtualBox-4.3.18']
  }
}

define virtualbox::extension($source, $creates) {
  $clean_source = strip($source)
  $basename = inline_template('<%= File.basename(clean_source) %>')

  Exec {
    creates => $creates
  }

  exec {
    "extension-download-${name}":
      command => "/usr/bin/curl -L ${clean_source} > '/tmp/$basename'",
      notify  => Exec["extension-install-${name}"];
    "extension-install-${name}":
      command     => "VBoxManage extpack install '/tmp/$basename'",
      user        => 'root',
      require     => Exec["extension-download-${name}"];
  }
}

