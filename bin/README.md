Here is how to use bin/api-test

Log into lab machine
```
cd dtk-client
bin/api-test test1
```
which has reponse
```
{"status"=>"ok",
 "data"=>
  {"service"=>{"name"=>"test1", "id"=>2147486175},
   "module"=>
    {"id"=>2147485436,
     "name"=>"workshop",
     "namespace"=>"scale15-lab",
     "version"=>"assembly--test1"},
   "repo"=>
    {"id"=>2147485432,
     "name"=>"sm-ubuntu-scale15-lab-workshop",
     "url"=>
      "ssh://dtk1@ec2-54-89-199-51.compute-1.amazonaws.com:2222/sm-ubuntu-scale15-lab-workshop"},
   "branch"=>
    {"name"=>"workspace-private-ubuntu--assembly-test1",
     "head_sha"=>"de3493dcfaa7bc38ad5185e81ac66cc0476ead50"}}}
 ```
 Example of an erros
```
bin/api-test test1
```
which has reponse
```
{"status"=>"notok",
 "errors"=>[{"code"=>"error", "message"=>"Service 'test1' already exists"}]}
 ```
ubuntu@ip-172-31-8-112:~/dtk-client$ dtk service uninstall -y --delete -n test1
[INFO] DTK module 'test1' has been uninstalled successfully.
```
