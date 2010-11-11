/*

= Class: bind::debian
Special debian class - inherits from bind::base

You should not include this class - please refer to Class["bind"]

*/
class bind::debian inherits bind::base {
  Service["bind9"] {
    pattern => "/usr/sbin/named",
  }
}
