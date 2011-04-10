grant all privileges to "SPARQL";
sparql clear graph <urn:test:graph> ;
sparql clear graph <urn:mv:graph> ;
ttlp_mt_local_file('test-data.ttl', '', 'urn:mv:graph' ) ;