#!/usr/bin/env bash

# select all of the family name
# psql -d flora_taiwan -q -c "COPY (SELECT family FROM family GROUP BY FAMILY) TO '/tmp/family';"


if [ -f ../dict_fam_entry ] ; then
    mv ../dict_fam_entry ../dict_fam_entry.bak &&
    :> ../dict_fam_entry
fi


if [ -d '/tmp/f' ] ; then
        mkdir -p /tmp/f
        chmod 777 /tmp/f
    else 
        rm -fr /tmp/f/*
fi

for i in `cat family`
do
  
 # select all of the species
  psql -d flora_taiwan -q -c "COPY (SELECT simple_sc,zh_name from namelist where family='${i}' order by family) TO '/tmp/f/${i}' DELIMITER AS ',' CSV QUOTE AS '\"';"
  dbzhfam=`psql -d flora_taiwan -q -c "SELECT fn_zh_name FROM family WHERE family='${i}'"`
  zhfam=`echo $dbzhfam | awk -F' ' '{print $3}'`
  family_species=`cat /tmp/f/${i} | sed -e 's/$/<br\/>/g'`
#  for x in `ls /tmp/f/`
#  do
#      cat ${x} | sed -e :x -e '$!N;s/\n/<br\/>\n/;tx'
#  done
# select Chinese name  

cat >> ../dict_fam_entry << _EOF
<d:entry id="${i}" d:title="${i}">
    <d:index d:value="${i}"/>
    <h1>${i}</h1>
        <p>
        ${family_species}
        </p>
</d:entry>

<d:entry id="${zhfam}" d:title="${zhfam}">
    <d:index d:value="${zhfam}"/>
    <h1>${zhfam}</h1>
        <p>
        ${family_species}
        </p>
</d:entry>
_EOF

done
