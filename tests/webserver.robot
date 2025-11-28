*** Settings ***
Library    SSHLibrary
Resource    api.resource

*** Keywords ***
Retry test
    [Arguments]    ${keyword}
    Wait Until Keyword Succeeds    60 seconds    1 second    ${keyword}

Backend URL is reachable
    ${rc} =    Execute Command    curl -f ${backend_url}/sftpgo
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

VirtualHost foo.com URL is reachable
    ${rc} =    Execute Command    curl -H "Host: foo.com" -f ${backend_url}
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

VirtualHost john.com URL is reachable
    ${rc} =    Execute Command    curl -H "Host: john.com" -f ${backend_url}
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

*** Test Cases ***
Check if webserver is installed correctly
    ${output}  ${rc} =    Execute Command    add-module ${IMAGE_URL} 1
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}  0
    &{output} =    Evaluate    ${output}
    Set Suite Variable    ${module_id}    ${output.module_id}

Check if webserver can be configured
    ${rc} =    Execute Command    api-cli run module/${module_id}/configure-module --data '{"path":"/sftpgo","http2https": true,"sftp_tcp_port": 3092,"sftpgo_service": true}'
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Retrieve webserver backend URL
    # Assuming the test is running on a single node cluster
    ${response} =    Run task     module/traefik1/get-route    {"instance":"${module_id}"}
    Set Suite Variable    ${backend_url}    ${response['url']}

Check if webserver works as expected
    Retry test    Backend URL is reachable

Check if vhost 9001 can be created
    ${rc} =    Execute Command    api-cli run module/${module_id}/create-vhost --data '{"PhpVersion":"","ServerNames":["foo.com"],"MemoryLimit":512,"AllowUrlfOpen":"disabled","UploadMaxFilesize":4,"PostMaxSize":8,"MaxExecutionTime":0,"MaxFileUploads":20,"lets_encrypt":false,"http2https":false,"Indexes":"disabled","status":"enabled"}'
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Check if vhost 9001 can be updated
    ${rc} =    Execute Command    api-cli run module/${module_id}/update-vhost --data '{"PhpVersion":"","ServerNames":["foo.com","john.com"],"Port":9001,"MemoryLimit":1024,"AllowUrlfOpen":"enabled","UploadMaxFilesize":8,"PostMaxSize":16,"MaxExecutionTime":100,"MaxFileUploads":40,"lets_encrypt":false,"http2https": false,"Indexes":"enabled","status":"enabled"}'
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Retrieve virtualhost foo.com backend URL
    # Assuming the test is running on a single node cluster
    ${response} =    Run task     module/traefik1/get-route    {"instance":"${module_id}-foo.com"}
    Set Suite Variable    ${backend_url}    ${response['url']}

Check if virtualhost foo.com works as expected
    Retry test    VirtualHost foo.com URL is reachable

Retrieve virtualhost john.com backend URL
    # Assuming the test is running on a single node cluster
    ${response} =    Run task     module/traefik1/get-route    {"instance":"${module_id}-john.com"}
    Set Suite Variable    ${backend_url}    ${response['url']}

Check if virtualhost john.com works as expected
    Retry test    VirtualHost john.com URL is reachable

Create a phpinfo to the 9001 vhost
    ${output}  ${rc} =    Execute Command    echo '<?php phpinfo();?>' > /home/${module_id}/.local/share/containers/storage/volumes/websites/_data/9001/phpinfo.php
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}  0

Check if vhost 9001 can use PHP74
    ${rc} =    Execute Command    api-cli run module/${module_id}/update-vhost --data '{"PhpVersion":"7.4","ServerNames":["foo.com","john.com"],"Port":9001,"MemoryLimit":2000,"AllowUrlfOpen":"enabled","UploadMaxFilesize":2000,"PostMaxSize":2000,"MaxExecutionTime":3600,"MaxFileUploads":20000,"lets_encrypt":true,"http2https":true,"Indexes":"enabled","status":"enabled"}'
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Check if virtualhost john.com works as expected after PHP74 update
    Retry test    VirtualHost john.com URL is reachable

Check if phpinfo.php uses PHP 7.4 with the custom settings
    ${output} =    Execute Command    curl -H "Host: john.com" ${backend_url}/phpinfo.php
    Should Contain    ${output}    PHP 7.4
    Should Contain    ${output}    <tr><td class="e">memory_limit</td><td class="v">2000M</td><td class="v">2000M</td></tr>
    Should Contain    ${output}    <tr><td class="e">allow_url_fopen</td><td class="v">On</td><td class="v">On</td></tr>
    Should Contain    ${output}    <tr><td class="e">upload_max_filesize</td><td class="v">2000M</td><td class="v">2000M</td></tr>
    Should Contain    ${output}    <tr><td class="e">post_max_size</td><td class="v">2000M</td><td class="v">2000M</td></tr>
    Should Contain    ${output}    <tr><td class="e">max_execution_time</td><td class="v">3600</td><td class="v">3600</td></tr>
    Should Contain    ${output}    <tr><td class="e">max_file_uploads</td><td class="v">20000</td><td class="v">20000</td></tr>

Check if vhost 9001 can use PHP80
    ${rc} =    Execute Command    api-cli run module/${module_id}/update-vhost --data '{"PhpVersion":"8.0","ServerNames":["foo.com","john.com"],"Port":9001,"MemoryLimit":2000,"AllowUrlfOpen":"enabled","UploadMaxFilesize":2000,"PostMaxSize":2000,"MaxExecutionTime":3600,"MaxFileUploads":20000,"lets_encrypt":true,"http2https":true,"Indexes":"enabled","status":"enabled"}'
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Check if virtualhost john.com works as expected after PHP80 update
    Retry test    VirtualHost john.com URL is reachable

Check if phpinfo.php uses PHP 8.0 with the custom settings
    ${output} =    Execute Command    curl -H "Host: john.com" ${backend_url}/phpinfo.php
    Should Contain    ${output}    PHP 8.0
    Should Contain    ${output}    <tr><td class="e">memory_limit</td><td class="v">2000M</td><td class="v">2000M</td></tr>
    Should Contain    ${output}    <tr><td class="e">allow_url_fopen</td><td class="v">On</td><td class="v">On</td></tr>
    Should Contain    ${output}    <tr><td class="e">upload_max_filesize</td><td class="v">2000M</td><td class="v">2000M</td></tr>
    Should Contain    ${output}    <tr><td class="e">post_max_size</td><td class="v">2000M</td><td class="v">2000M</td></tr>
    Should Contain    ${output}    <tr><td class="e">max_execution_time</td><td class="v">3600</td><td class="v">3600</td></tr>
    Should Contain    ${output}    <tr><td class="e">max_file_uploads</td><td class="v">20000</td><td class="v">20000</td></tr>

Check if vhost 9001 can use PHP81
    ${rc} =    Execute Command    api-cli run module/${module_id}/update-vhost --data '{"PhpVersion":"8.1","ServerNames":["foo.com","john.com"],"Port":9001,"MemoryLimit":2000,"AllowUrlfOpen":"enabled","UploadMaxFilesize":2000,"PostMaxSize":2000,"MaxExecutionTime":3600,"MaxFileUploads":20000,"lets_encrypt":true,"http2https":true,"Indexes":"enabled","status":"enabled"}'
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Check if virtualhost john.com works as expected after PHP81 update
    Retry test    VirtualHost john.com URL is reachable

Check if phpinfo.php uses PHP 8.1 with the custom settings
    ${output} =    Execute Command    curl -H "Host: john.com" ${backend_url}/phpinfo.php
    Should Contain    ${output}    PHP 8.1
    Should Contain    ${output}    <tr><td class="e">memory_limit</td><td class="v">2000M</td><td class="v">2000M</td></tr>
    Should Contain    ${output}    <tr><td class="e">allow_url_fopen</td><td class="v">On</td><td class="v">On</td></tr>
    Should Contain    ${output}    <tr><td class="e">upload_max_filesize</td><td class="v">2000M</td><td class="v">2000M</td></tr>
    Should Contain    ${output}    <tr><td class="e">post_max_size</td><td class="v">2000M</td><td class="v">2000M</td></tr>
    Should Contain    ${output}    <tr><td class="e">max_execution_time</td><td class="v">3600</td><td class="v">3600</td></tr>
    Should Contain    ${output}    <tr><td class="e">max_file_uploads</td><td class="v">20000</td><td class="v">20000</td></tr>

Check if vhost 9001 can use PHP82
    ${rc} =    Execute Command    api-cli run module/${module_id}/update-vhost --data '{"PhpVersion":"8.2","ServerNames":["foo.com","john.com"],"Port":9001,"MemoryLimit":2000,"AllowUrlfOpen":"enabled","UploadMaxFilesize":2000,"PostMaxSize":2000,"MaxExecutionTime":3600,"MaxFileUploads":20000,"lets_encrypt":true,"http2https":true,"Indexes":"enabled","status":"enabled"}'
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Check if virtualhost john.com works as expected after PHP82 update
    Retry test    VirtualHost john.com URL is reachable

Check if phpinfo.php uses PHP 8.2 with the custom settings
    ${output} =    Execute Command    curl -H "Host: john.com" ${backend_url}/phpinfo.php
    Should Contain    ${output}    PHP 8.2
    Should Contain    ${output}    <tr><td class="e">memory_limit</td><td class="v">2000M</td><td class="v">2000M</td></tr>
    Should Contain    ${output}    <tr><td class="e">allow_url_fopen</td><td class="v">On</td><td class="v">On</td></tr>
    Should Contain    ${output}    <tr><td class="e">upload_max_filesize</td><td class="v">2000M</td><td class="v">2000M</td></tr>
    Should Contain    ${output}    <tr><td class="e">post_max_size</td><td class="v">2000M</td><td class="v">2000M</td></tr>
    Should Contain    ${output}    <tr><td class="e">max_execution_time</td><td class="v">3600</td><td class="v">3600</td></tr>
    Should Contain    ${output}    <tr><td class="e">max_file_uploads</td><td class="v">20000</td><td class="v">20000</td></tr>

Check if vhost 9001 can use PHP83
    ${rc} =    Execute Command    api-cli run module/${module_id}/update-vhost --data '{"PhpVersion":"8.3","ServerNames":["foo.com","john.com"],"Port":9001,"MemoryLimit":2000,"AllowUrlfOpen":"enabled","UploadMaxFilesize":2000,"PostMaxSize":2000,"MaxExecutionTime":3600,"MaxFileUploads":20000,"lets_encrypt":true,"http2https":true,"Indexes":"enabled","status":"enabled"}'
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Check if virtualhost john.com works as expected after PHP83 update
    Retry test    VirtualHost john.com URL is reachable

Check if phpinfo.php uses PHP 8.3 with the custom settings
    ${output} =    Execute Command    curl -H "Host: john.com" ${backend_url}/phpinfo.php
    Should Contain    ${output}    PHP 8.3
    Should Contain    ${output}    <tr><td class="e">memory_limit</td><td class="v">2000M</td><td class="v">2000M</td></tr>
    Should Contain    ${output}    <tr><td class="e">allow_url_fopen</td><td class="v">On</td><td class="v">On</td></tr>
    Should Contain    ${output}    <tr><td class="e">upload_max_filesize</td><td class="v">2000M</td><td class="v">2000M</td></tr>
    Should Contain    ${output}    <tr><td class="e">post_max_size</td><td class="v">2000M</td><td class="v">2000M</td></tr>
    Should Contain    ${output}    <tr><td class="e">max_execution_time</td><td class="v">3600</td><td class="v">3600</td></tr>
    Should Contain    ${output}    <tr><td class="e">max_file_uploads</td><td class="v">20000</td><td class="v">20000</td></tr>

Check if vhost 9001 can use PHP84
    ${rc} =    Execute Command    api-cli run module/${module_id}/update-vhost --data '{"PhpVersion":"8.4","ServerNames":["foo.com","john.com"],"Port":9001,"MemoryLimit":2000,"AllowUrlfOpen":"enabled","UploadMaxFilesize":2000,"PostMaxSize":2000,"MaxExecutionTime":3600,"MaxFileUploads":20000,"lets_encrypt":true,"http2https":true,"Indexes":"enabled","status":"enabled"}'
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Check if virtualhost john.com works as expected after PHP84 update
    Retry test    VirtualHost john.com URL is reachable

Check if phpinfo.php uses PHP 8.4 with the custom settings
    ${output} =    Execute Command    curl -H "Host: john.com" ${backend_url}/phpinfo.php
    Should Contain    ${output}    PHP 8.4
    Should Contain    ${output}    <tr><td class="e">memory_limit</td><td class="v">2000M</td><td class="v">2000M</td></tr>
    Should Contain    ${output}    <tr><td class="e">allow_url_fopen</td><td class="v">On</td><td class="v">On</td></tr>
    Should Contain    ${output}    <tr><td class="e">upload_max_filesize</td><td class="v">2000M</td><td class="v">2000M</td></tr>
    Should Contain    ${output}    <tr><td class="e">post_max_size</td><td class="v">2000M</td><td class="v">2000M</td></tr>
    Should Contain    ${output}    <tr><td class="e">max_execution_time</td><td class="v">3600</td><td class="v">3600</td></tr>
    Should Contain    ${output}    <tr><td class="e">max_file_uploads</td><td class="v">20000</td><td class="v">20000</td></tr>

Login to sftpgo as user 9001 password 9001
    Put File    ${CURDIR}/test-sftpgo-login.sh    /tmp/test-sftpgo-login.sh
    ${user} =    Set Variable    u3@domain.test
    ${out}  ${err}  ${rc} =    Execute Command
    ...    bash /tmp/test-sftpgo-login.sh
    ...    return_rc=True    return_stderr=True
    Log    Login helper stdout: ${out}
    Log    Login helper stderr: ${err}
    Log    Login helper stderr: ${rc}
    Should Be Equal As Integers    ${rc}  0
    should Be Empty    ${err}
    should Be Empty    ${out}

Login to sftpgo as user admin password admin
    Put File    ${CURDIR}/test-sftpgo-admin-login.sh    /tmp/test-sftpgo-admin-login.sh
    ${user} =    Set Variable    u3@domain.test
    ${out}  ${err}  ${rc} =    Execute Command
    ...    bash /tmp/test-sftpgo-admin-login.sh
    ...    return_rc=True    return_stderr=True
    Log    Login helper stdout: ${out}
    Log    Login helper stderr: ${err}
    Log    Login helper stderr: ${rc}
    Should Be Equal As Integers    ${rc}  0
    should Be Empty    ${err}
    should Be Empty    ${out}

Check if vhost can be destroyed
    ${rc} =    Execute Command    api-cli run module/${module_id}/destroy-vhost --data '{"ServerNames": ["foo.com","john.com"],"port": 9001}'
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0


Check if webserver is removed correctly
    ${rc} =    Execute Command    remove-module --no-preserve ${module_id}
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0
