#!/bin/bash
HOST_A='10.10.10.138'               #Keystone host to gen token (Ha Noi)
HOST_B='10.10.10.139'               #Keystone host to validate token (HoChiMinh)
result=/root/keystone/result.txt        #Ket qua kiem tra lan luot.
ketqua=/root/keystone/ketqua.txt       #Ket qua trung gian de tinh trung binh.
trungbinh=/root/keystone/trungbinh.txt      #Ket qua trung binh
time_check_a_token=7200       #Total time to validate a token in sec
time_sleep=1                   #Time sleep between each validation in sec
username=admin             #user for gen token
password=Welcome123   #password for gen token
domain=default               #domain for gen token
project=admin                 #project for gen token
count_gen_token=3          #Tao bao nhieu token trong 1 lan chay?
count_vali=10                   #1 token kiem tra 10 lan
###count
count_token=0
count_token_failed=0
count_token_success=0
count_vali_failed=0
count_vali_success=0    
tong=0                          #Tong so validate token
s_token_success=0
s_token=0
s_vali_success=0
s_vali=0

gen_token(){
    echo ----------------------------------------------------------------------------------------- | tee -a $result
    start=`date +%s`
    token=`python /root/check_keystone_v3 --username $username --password $password --domain $domain --project $project --auth_url http://$HOST_A:35357/v3`
    ((count_token++))
    if [ $token == "" ]
    then
        echo -e `date` "\t" 0 "\t\t\t" | tee -a $result
        ((count_token_failed++))
        gen_token
    else
        echo -e `date` "\t" 1 "\t\t\t" | tee -a $result
        ((count_token_success++))
        validate_token
    fi
}
validate_token(){
for i in `seq 1 $count_vali`;
do
    for host in $HOST_B; do
            end=`date +%s`
            if [[ $((end-start)) -le $time_check_a_token ]]
            then
                python /root/validate_keystone_v3 --token $token --auth_url http://$host:35357/v3
                if [ $? -eq 2 ]
                then
                    echo -e `date` "\t"  "\t\t\t" 0 | tee -a $result
                    ((count_vali_failed++))
                else
                    echo -e `date` "\t"  "\t\t\t" 1 | tee -a $result
                    ((count_vali_success++))
                fi
                ((tong++))
            fi
    done
    sleep $time_sleep
done
}
echo ----------------------------------------------------------------------------------------- | tee -a $result
echo -e Thoi Gian "\t\t\t" gen thanh cong "\t" validate thanh cong | tee -a $result
while [[ $count_token -lt $count_gen_token ]]; do
    gen_token
done
echo -----------------------------------------------------------------------------------------
echo -e `date` "|" $count_token_success "|" $count_token "|" $count_vali_success "|" $tong | tee -a $ketqua
# If file exists 
if [[ -f "$ketqua" ]]
then
    while IFS='|' read -r ngaygio count_token_success_2 count_token_2 count_vali_success_2 count_vali_2
    do
        ((s_token_success+=$count_token_success_2))
        ((s_token+=$count_token_2))
        ((s_vali_success+=$count_vali_success_2))
        ((s_vali+=$count_vali_2))
    done <"$ketqua"
fi
tb1=$(echo "scale=2;$s_token_success / $s_token * 100" | bc)
tb2=$(echo "scale=2;$s_vali_success / $s_vali * 100" | bc)
echo -e Gen: $tb1% "\t" Vali: $tb2% | tee $trungbinh