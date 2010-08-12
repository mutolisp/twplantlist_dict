#!/usr/bin/env bash

if [ -f ../dict_gen_entry ] ; then
    mv ../dict_gen_entry ../dict_gen_entry.bak &&
    :> ../dict_gen_entry
fi


if [ -d '/tmp/g' ] ; then
        mkdir -p /tmp/g
        chmod 777 /tmp/g
fi

for gen in `cat genus` 
    do 
        psql -d flora_taiwan -c "COPY (SELECT simple_sc,zh_name FROM namelist WHERE genus='${gen}') TO '/tmp/g/${gen}';";
        gen_species=`cat /tmp/g/${gen} | sed -e 's/$/<br\/>/g'`
        echo "Processing ${gen}..."

cat >> ../dict_gen_entry << _EOF
<d:entry id="${gen}" d:title="${gen}">
    <d:index d:value="${gen}"/>
    <d:index d:value="${gen}屬"/>    <h1>${gen}</h1>
        <p>
        ${gen_species}
        </p>
</d:entry>
_EOF

done
