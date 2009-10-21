#!/usr/bin/env bash 
#namelist=namelist.csv
namelist=1_2k
i=1
for s in `cat ${namelist} | awk -F',' '{ print $3}'`
    do 
    # eliminate strange ^H
    #sed -i "" s'/_//g' ${i}.txt
    # check conditions: 1. no records 2. exactly 3.multiple records
    echo "######## BEGIN of ${i} ########"
    ##### NO RECORDS #######
    if [ `grep "No records found" ${i}.txt | wc -l` -gt 0 ]; then
        echo "Condition 1"
        echo "No records found of ${s}!"
        family=`cat ${namelist} | grep ${s} | awk -F',' '{print $2}'`
        tropicos_fam=NULL
        tropicos=NULL
    ##### FIND RECORDS ######
    elif [ `grep "Records" ${i}.txt | wc -l` -gt 0 ]; then
        echo "Condition 2"
        echo "Processing multiple records"
        # get the family name
        family=`cat ${namelist} | grep ${s} | awk -F',' '{print $2}'`
        # if there are multiple results, get the correct one,  "!"
        if [ `grep ${family} ${i}.txt | grep ! | wc -l` -eq 1 ]; then
            tropicos_raw=`cat ${i}.txt | grep ${family} | grep !`
            tropicos_fam=`echo ${tropicos_raw} | awk '{ print $1 }'`
            # process with var.
            # if [ `cat ${i}.txt | grep ${family}.txt | grep " var. " | wc -l` -eq 1 \
            #      -o `cat ${i}.txt | grep ${family}.txt | grep " subsp. " | wc -l` -eq 1  \
            #      -o `cat ${i}.txt | grep ${family}.txt | grep " cv. " | wc -l` -eq 1 \
            #      -o `cat ${i}.txt | grep ${family}.txt | grep " x " | wc -l` -eq 1 ]; then
            #         cat  ${i}.txt 
            #         echo "${tropicos_raw}, author?"
            #         read author
            #         echo "tropicos name?"
            #         read tropicos
            #         echo "publish"
            #         read publish
            #         echo "and year?"
            #         read year
            #         echo ${tropicos}, ${author}, ${publish}, ${year}
            #     else 
            #      # cat ${i}.txt
            #      # echo "author?"
            #      # read author
            #      # echo "publish?"
            #      # read publish
            #      # echo "year?"
            #      # read year
            #       echo ${author}, ${publish}, ${year}
            #      # tropicos=`echo ${tropicos_raw} | awk '{ print $3, $4 }'`
            # fi
        else
            # check var and subsp
            if [ `echo ${s} | awk -F',' '{print $3}' | grep "+var." | wc -l` -eq 1 ] && [ `echo ${s} | awk -F',' '{print $3}' | grep "+subsp." | wc -l` != 1] ; then
                tropicos_raw=`cat ${i}.txt | grep ${family} | awk 'NR == 1'`
                tropicos=`echo ${tropicos_raw} | awk '{ print $2, $3, $4, $5}'`
                str_leng=`echo "${tropicos_raw}" | wc -w`
                tr_num=`echo ${str_leng}-1 | bc -l`
                author_publish=`echo ${tropicos} | awk '{ for (i=6;i<"'"${tr_num}"'";i++ ) { print $i }}' | sed -e :x -e '$!N;s/\n/ / ;tx'`
                year=`echo ${tropicos} | awk '{print $"'"${str_leng}"'" }'`
            elif [ `echo ${s} | awk -F',' '{print $3}' | grep "+subsp." | wc -l` -eq 1 ] && [`echo ${s} | awk -F',' '{print $3}' | grep "+var." | wc -l` != 1] ; then
                tropicos_raw=`cat ${i}.txt | grep ${family} | awk 'NR == 1'`
                tropicos=`echo ${tropicos_raw} | awk '{ print $2, $3, $4, $5}'`
                str_leng=`echo "${tropicos_raw}" | wc -w`
                tr_num=`echo ${str_leng}-1 | bc -l`
                author_publish=`echo ${tropicos} | awk '{ for (i=6;i<"'"${tr_num}"'";i++ ) { print $i }}' | sed -e :x -e '$!N;s/\n/ / ;tx'`
                year=`echo ${tropicos} | awk '{ print $"'"${str_leng}"'" }'`
            else
                tropicos_raw=`cat ${i}.txt | grep ${family} | awk 'NR == 1'`
                tropicos=`echo ${tropicos_raw} | awk '{ print $2, $3}'`
                str_leng=`echo "${tropicos_raw}" | wc -w`
                tr_num=`echo ${str_leng}-1 | bc -l`
                author_publish=`echo ${tropicos} | awk '{ for (i=4;i<"'"${tr_num}"'";i++ ) { print $i }}' | sed -e :x -e '$!N;s/\n/ / ;tx'`
                year=`echo ${tropicos_raw} | awk '{ print $"'"${str_leng}"'" }'`
            fi
            #tropicos_fam=`echo ${tropicos_raw} | awk '{ print $1 }'`
            #tropicos=`echo ${tropicos_raw} | awk '{ print $2, $3}'`
            publish=${author_publish}
        fi
    ###### Match our scientific name #####
    elif [ `grep "Records" ${i}.txt | wc -l` -eq 0 ]; then
        echo "Condition 3"
        echo "This scientific name is coherent to our flora.... Processing ..."
        ########
        # original family name in flora, and data like the following
        # 993,Portulacaceae,Portulaca+pilosa
        #########

        family=`cat ${namelist} | grep ${s} | awk -F',' '{print $2}'` 

        ########
        # tropicos family
        # original data example:"* family: Clusiaceae Lindl."
        ########

        tropicos_fam=`cat ${i}.txt | grep family | awk -F' ' '{print $3}'`

        ########
        # tropicos scientific name,
        # for example, Hypericum nokoense Ohwi
        ########

        name=`cat ${i}.txt | grep "Print-friendly page view     Decrease font" |  awk -F'Print-friendly' '{ print $1}'`
        tropicos=`echo ${name} | awk '{ print $1, $2}'`

        ##### BEGIN of check author ######
        if [ `echo ${name} | grep " var. " | wc -l` -eq 1  ]; then
            echo "Please manually process this: (tropicos=?)"
            echo ${name}
            read tropicos
            echo "And author?"
            read author
            echo "The simple scientific name is ${tropicos}, and author is ${author}. Keep checking..."
        else
            # catch author
            if [ `echo ${name} | wc -w` -gt 3  ]; then
                num_author=`echo ${name} | wc -w`
                for (( nauthor=3 ; nauthor<=${num_author} ; nauthor++))
                        do echo ${nauthor} >> t
                     done
                        pre1=`cat t | sed -e :x -e '$!N;s/\n/, $/;tx'`
                        pre_author=`echo -e "$"${pre1}`
                        # clear t
                        :> t
                        awk_begin=`echo "awk -F' ' '{ print "`
                        awk_end=`echo " }'"`
                        echo ${name} > name_test
                        echo "${awk_begin}${pre_author}${awk_end} name_test" > eawk
                        chmod +x eawk
                        author=`./eawk`
                elif [ `echo ${name} | wc -w` -eq 3 ]; then
                    author=`echo ${name} | awk '{ print $3 }'`
                else
                    echo "Exception caught!"
            fi 
        fi
        ##### END of check author #####

        #####
        # Extract
        publish_raw=`cat ${i}.txt | grep "Published In" | awk -F'Published In: ' '{ print $2 }' | awk -F'Name publication detail' '{print $1}'`

        #psql -d flora_taiwan -q -c "UPDATE namelist SET tropicos_fam='${tropicos_fam}', tropicos='', 
        #            author='${author}', publish='', year='' "
    else
        echo "Exception caught!"
    fi
    #echo "\"${i}\",\"${tropicos}\",\"${s}\"" >> CORRECT_NAMES
    echo "\"${i}\", \"${family}\", \"${tropicos_fam}\", \"${tropicos}\", \"${author}\", \"${publish_raw}\",\"${year}\"" >> Z_tropicos_names
    echo "######### END of ${i} ##############"
    let i+=1
done
