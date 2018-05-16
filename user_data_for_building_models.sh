sudo apt-get install -y libcurl4-openssl-dev
sudo apt-get install -y r-base-core
sudo apt-get install -y default-jre
R -e 'install.packages(c("packrat"))'
R -e 'packrat::init()'