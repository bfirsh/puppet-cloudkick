class cloudkick {

    exec { 
        "apt-get update":
            command => "/usr/bin/apt-get update",
            refreshonly => true
        ;
        "cloudkick key":
            command => "/usr/bin/curl http://packages.cloudkick.com/cloudkick.packages.key | /usr/bin/apt-key add -",
            unless => "/usr/bin/apt-key list | /bin/grep -Fqe Cloudkick",
        ;
    }
    
    file {
        "/etc/apt/sources.list.d/cloudkick.com.list":
            ensure => present,
            content => "deb http://packages.cloudkick.com/ubuntu lucid main",
            require => Exec["cloudkick key"],
            notify => Exec["apt-get update"],
        ;
        ['/usr/lib/cloudkick-agent']:
            ensure => directory
        ;
        cloudkick-plugins:
            path => "/usr/lib/cloudkick-agent/plugins/",
            recurse => true,
            mode => 0755,
            purge => true,
            require => File['/usr/lib/cloudkick-agent'],
            source => "puppet://$servername/modules/cloudkick/plugins/",
        ;

        "/etc/cloudkick.conf":
            content => template("cloudkick/cloudkick.conf.erb")
        ;
    }
     
    package {
        cloudkick-agent:
            ensure => latest,
            require => [
                File["/etc/apt/sources.list.d/cloudkick.com.list"],
                File["/etc/cloudkick.conf"],
            ]
        ;
    }
    service {
        "cloudkick-agent":
            enable => true,
            ensure => running,
            require => Package["cloudkick-agent"],
            subscribe => File["/etc/cloudkick.conf"],
        ;

    }
}

