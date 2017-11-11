node 'test31.fen9.li' {
  include role::webserver
}

#node 'test32.fen9.li' {
#  include role::base
#}

node /esnode4[1-9].fen9.li/ {
  include role::elasticsearchnode
}

node 'ruby81.fen9.li' {
  include role::ruby
}
