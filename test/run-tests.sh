cd db
sh 2-init-db.sh
cd ..

coffee -c sparql.test.coffee
expresso *.test.js