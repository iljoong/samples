# Samples

$rgname = "ragname"
$myvmss = "vmss"
$vmimage = "/subscriptions/.../Microsoft.Compute/images/cicdimagev2"

# update instance model
az vmss update -n $myvmss -g $rgname --set virtualMachineProfile.storageProfile.imageReference.id=$vmimage

# all at once
az vmss update-instances -n $myvmss -g $rgname --instance-ids "*"

# rolling upgrade
az vmss get-instance-view -n $myvmss -g $rgname  --instance-id "*" \
  --query "[].[instanceView.platformUpdateDomain, instanceId]" -o tsv \
 | sort \
 | awk -v myvmss=$myvmss -v rgname=$rgname '{print "az vmss update-instances -n " myvmss " -g " rgname " --instance-ids " $2}' \
 | bash 

# immutable
az vmss scale --n $myvmss -g $rgname  --new-capacity 8
az vmss delete-instances -n $myvmss -g $rgname  --instance-ids 1 2 3 4

# immutable (advanced)
az vmss list-instances -n $myvmss -g $rgname  \
  --query '[?!latestModelApplied].instanceId | join(`" "`, @)' \
  | awk -v myvmss=$myvmss -v rgname=$rgname '{print "az vmss delete-instances -n " myvmss " -g " rgname " --instance-ids " $1}' \
  | sed 's/"//g' | bash

# rolling upgrade (advanced)
az vmss get-instance-view -n $myvmss -g $rgname  --instance-id "*" \
  --query "[].[instanceView.platformUpdateDomain, instanceId]" -o tsv \
 | sort \
 | awk 'BEGIN {} {a[$1] = a[$1] "@" $2 } END {for (i in a) printf("%s %s\n", i, a[i])} ' \
 | sort \
 | awk -v myvmss=$myvmss -v rgname=$rgname '{print "az vmss update-instances -n " myvmss " -g " rgname " --instance-ids " $2}' \
 | sed s/@/' '/g \
 | bash 




