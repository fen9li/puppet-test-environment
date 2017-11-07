node 'test31.fen9.li' {
  include role::webserver
}

node /esnode4[1-9].fen9.li/ {
  include role::elasticsearchnode
}
