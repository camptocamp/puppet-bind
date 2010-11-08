class bind {
  case $operatingsystem {
    "Debian": { include bind::debian }
    default: { fail "Unknown $operatingsystem" }
  }
}
