  $base_packages = [
    "automake",
    "bison",
    "doxygen",
    "ethtool",
    "flex",
    "g++",
    "ipython",
    "ipython-notebook",
    "libany-moose-perl",
    "libboost-dev",
    "libboost-filesystem-dev",
    "libboost-program-options-dev",
    "libboost-system-dev",
    "libboost-test-dev",
    "libbsd-dev",
    "libedit-dev",
    "libevent-dev",
    "libfreetype6-dev",
    "libhiredis-dev",
    "libjudy-dev",
    "libpcap-dev",
    "libpng-dev",
    "libssl-dev",
    "libtool",
    "libyaml-0-2",
    "libbz2-dev",
    "mininet",
    "openssl",
    "pkg-config",
    "python-dev",
    "python-dpkt",
    "python-jsonpickle",
    "python-imaging-tk",
    "python-matplotlib",
    "python-nose",
    "python-numpy",
    "python-pandas",
    "python-pip",
    "python-pygraph",
    "python-pygraphviz",
    "python-scipy",
    "python-setuptools",
    "python-sympy",
    "python-yaml",
    "redis-server",
    "thrift-compiler",
    "wireshark",
    "git",
    "vim"
  ]

  exec { "aptupdate":
    command => "apt-get update",
    path    => ["/bin", "/usr/bin"],
  }

  package { $base_packages:
    ensure  => [installed, latest],
    require => Exec['aptupdate'],
  }

  notice("Base dependencies successfully installed.")

  notice("Installing thift from source, this may take a while...")

  exec { "download_thrift":
    command => "wget http://mirror.csclub.uwaterloo.ca/apache/thrift/0.9.2/thrift-0.9.2.tar.gz",
    path    => ["/bin", "/usr/bin"],
    cwd     => "/p4",
    creates => "/p4/thrift-0.9.2.tar.gz",
    require => Package[$base_packages],
  }

  exec { "extract_thrift":
    command => "tar xf thrift-0.9.2.tar.gz",
    path    => ["/bin", "/usr/bin"],
    cwd     => "/p4",
    creates => "/p4/thrift-0.9.2/README.md",
    require => [Package[$base_packages],
                Exec['download_thrift']],
  }

  exec { "configure_thrift":
    command => "sh ./configure",
    cwd     => "/p4/thrift-0.9.2/",
    path    => ["/bin", "/usr/bin"],
    require => [Package[$base_packages],
                Exec['extract_thrift']],
    timeout     => 0,
  }

  exec { "make_thrift":
    command => "make",
    cwd     => "/p4/thrift-0.9.2/",
    path    => ["/bin", "/usr/bin"],
    require => [Package[$base_packages],
                Exec['configure_thrift']],
    timeout     => 0,
  }

  exec { "make_install_thrift":
    command => "make install",
    cwd     => "/p4/thrift-0.9.2/",
    path    => ["/bin", "/usr/bin"],
    require => [Package[$base_packages],
                Exec['make_thrift']],
    timeout     => 0,
  }

  exec { "install_python_thrift_library":
    command => "python setup.py install",
    cwd     => "/p4/thrift-0.9.2/lib/py/",
    path    => ["/bin", "/usr/bin"],
    require => [Package[$base_packages],
                Exec['make_install_thrift']],
    timeout     => 0,
  }

  exec { "mkdirp4":
    command => "/bin/mkdir -p /p4",
    cwd     => "/",
    path    => ["/bin", "/usr/bin"],
  }

  file { [
            "/p4",
         ]:
    ensure  => directory,
  }

  notice("Installing high level interpreter and scapy...")

  exec { "clonep4hlir":
    command => "git clone https://github.com/p4lang/p4-hlir.git",
    cwd     => "/p4",
    path    => ["/bin", "/usr/bin"],
    creates => "/p4/p4-hlir/setup.py",
    require => Package[$base_packages],
  }

  exec { "installp4hlir":
    command => "python setup.py install",
    cwd     => "/p4/p4-hlir",
    path    => ["/bin", "/usr/bin"],
    require => Exec['clonep4hlir'],
  }

notice("Installing P4 dependency graph generator...")

  exec { "clonep4cgraph":
    command => "git clone https://github.com/p4lang/p4c-graphs.git",
    cwd     => "/p4",
    path    => ["/bin", "/usr/bin"],
    creates => "/p4/p4c-graphs/setup.py",
    require => Package[$base_packages],
  }

  exec { "installp4cgraph":
    command => "python setup.py install",
    cwd     => "/p4/p4c-graphs/",
    path    => ["/bin", "/usr/bin"],
    require => Exec['clonep4cgraph'],
  }

  notice("Installing scapy vxlan...")

  exec { "clonescapyvxlan":
    command => "git clone https://github.com/p4lang/scapy-vxlan.git",
    cwd     => "/p4",
    path    => ["/bin", "/usr/bin"],
    creates => "/p4/scapy-vxlan/setup.py",
    require => Package[$base_packages],
  }

  exec { "installscapyvxlan":
    command => "python setup.py install",
    cwd     => "/p4/scapy-vxlan/",
    path    => ["/bin", "/usr/bin"],
    require => Exec['clonep4cgraph'],
  }

    notice("Cloning p4factory...")

  exec { "clonep4factory":
    command => "git clone https://github.com/p4lang/p4factory.git",
    cwd     => "/p4",
    path    => ["/bin", "/usr/bin"],
    creates => "/p4/p4factory/install.sh",
    require => Package[$base_packages],
  }

  case $autorun {
    'no' :  { 
              exec { "cloneonly":
                command => "git clone $softswitch",
                cwd     => "/p4",
                path    => ["/bin", "/usr/bin"],
                require => Package[$base_packages],
              }
            }
    'yes' : {
              exec { "cloneandrun":
                command => "git clone $softswitch",
                cwd     => "/p4",
                path    => ["/bin", "/usr/bin"],
                require => Package[$base_packages],
              }
            }
  }

  exec { "clonesoftswitch":
    command => "git clone $softswitch",
    cwd     => "/p4",
    path    => ["/bin", "/usr/bin"],
    require => Package[$base_packages],
  }