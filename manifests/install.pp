define rbenv::install ( $user, $shell ) {
  Exec["checkout rbenv"] -> Exec["configure rbenv path"] -> Exec["configure rbenv init"] -> Exec["checkout ruby-build"] -> Exec["install ruby-build"]
  # STEP 1
  exec { "checkout rbenv":
    command => "git clone git://github.com/sstephenson/rbenv.git .rbenv",
    user    => $user,
    group   => $user,
    cwd     => "/home/${user}",
    creates => "/home/${user}/.rbenv/bin/rbenv",
    path    => ["/usr/bin", "/usr/sbin"],
    timeout => 100,
    require => Package['git-core'],
  }


  exec { "configure rbenv path":
    command => "echo 'export PATH=\$HOME/.rbenv/bin:\$PATH' >> /home/${user}/.${shell}rc",
    user    => $user,
    group   => $user,
    cwd     => "/home/${user}",
    onlyif  => "[ -f /home/${user}/.${shell}rc ]",
    unless  => "grep 'rbenv/bin' /home/${user}/.${shell}rc 2>/dev/null",
    path    => ["/bin", "/usr/bin", "/usr/sbin"],
    require => [Rbenv::Support::Line["remove PATH from ${shell}rc"], Rbenv::Support::Line["remove rbenv-init from ${shell}rc"]],
  }

  exec { "configure rbenv init":
    command => "echo 'eval \"\$(rbenv init -)\"' >> /home/${user}/.${shell}rc",
    user    => $user,
    group   => $user,
    cwd     => "/home/${user}",
    onlyif  => "[ -f /home/${user}/.${shell}rc ]",
    unless  => "grep 'rbenv init -' /home/${user}/.${shell}rc 2>/dev/null",
    path    => ["/bin", "/usr/bin", "/usr/sbin"],
    require => [Rbenv::Support::Line["remove PATH from ${shell}rc"], Rbenv::Support::Line["remove rbenv-init from ${shell}rc"]],
  }

  exec { "checkout ruby-build":
    command => "git clone git://github.com/sstephenson/ruby-build.git",
    user    => $user,
    group   => $user,
    cwd     => "/home/${user}",
    creates => "/home/${user}/ruby-build",
    path    => ["/usr/bin", "/usr/sbin"],
    timeout => 100,
  }

  exec { "install ruby-build":
    command => "sh install.sh",
    user    => "root",
    group   => "root",
    cwd     => "/home/${user}/ruby-build",
    onlyif  => '[ -z "$(which ruby-build)" ]',
    path    => ["/bin", "/usr/local/bin", "/usr/bin", "/usr/sbin"],
    require => Package["zlib1g-dev"],
  }

  rbenv::support::line { "remove PATH from ${shell}rc":
    file => "/home/${user}/.${shell}rc",
    ensure => absent,
    line => 'export PATH=$HOME/.rbenv/bin:$PATH',
  }

  rbenv::support::line { "remove rbenv-init from ${shell}rc":
    file => "/home/${user}/.${shell}rc",
    ensure => absent,
    line => 'eval "$(rbenv init -)"',
  } 
}
