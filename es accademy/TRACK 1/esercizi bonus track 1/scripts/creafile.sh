#!/usr/bin/env bash

read -p "inserisci nome nuovo file: " name
read -p "inserisci estensione: " ext
touch $name.$ext
chmod +x $name.$ext
echo "#!/usr/bin/env bash" > $name.$ext
vi $name.$ext

~                                               
~                                               
~                                               
~                                               
~                                               
~                                               
~                                               
~                                               
~                                               
~                                               
~                                               
~                                               
~                                               
