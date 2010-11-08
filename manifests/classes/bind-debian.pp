class bind::debian inherits bind::base {
  Service["bind9"] {
    pattern => "/usr/sbin/named",
  }
}
