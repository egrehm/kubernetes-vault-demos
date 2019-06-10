#! /bin/bash

f_


for i in red green blue; do  
  export SECRETPATH=cluster/demo
  vault write secret/$SECRETPATH/$i/registry value=$i 
  export APP=$i
  ./k8s-demo/setup-k8s-auth.sh 
done


