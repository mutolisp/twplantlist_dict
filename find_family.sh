#!/usr/bin/env bash

# select all of the family name
# psql -d flora_taiwan -q -c "COPY (SELECT family FROM family GROUP BY FAMILY) TO '/tmp/family';"

for i in `cat family`
do
  
 # select all of the species
  psql -d flora_taiwan -q -c "COPY (SELECT simple_sc,zh_name from namelist where family='${i}' order by family) TO '/tmp/f/${i}' DELIMITER AS ',' CSV QUOTE AS '\"';"
  family_species=`cat /tmp/f/${i}`
  for x in `ls /tmp/f/`
  do
      cat ${x} | sed -e :x -e '$!N;s/\n/<br\/>\n/;tx'
  done
 # select Chinese name  

# cat >> dict_fam_entry << _EOF
# <d:entry id="${i}" d:title="${i}">
#     <d:index d:value="${i}"/>
#     <h1>${i}</h1>
#         <p>
#         ${family_species}
#         </p>
# </d:entry>
# _EOF

done


