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


*** Test Cases ***
Check if webserver is installed correctly
    ${output}  ${rc} =    Execute Command    add-module ${IMAGE_URL} 1
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}  0
    &{output} =    Evaluate    ${output}
    Set Suite Variable    ${module_id}    ${output.module_id}

Check if webserver can be configured
    ${rc} =    Execute Command    api-cli run module/${module_id}/configure-module --data '{"path":"/sftpgo","http2https": true,"sftp_tcp_port": 2092,"sftpgo_service": true}'
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Retrieve webserver backend URL
    # Assuming the test is running on a single node cluster
    ${response} =    Run task     module/traefik1/get-route    {"instance":"${module_id}"}
    Set Suite Variable    ${backend_url}    ${response['url']}

Check if webserver works as expected
    Retry test    Backend URL is reachable

Check if vhost can be created
    ${rc} =    Execute Command    api-cli run module/${module_id}/create-vhost --data '{"PhpVersion":"8.2","ServerNames":["foo.com","john.com"],"MemoryLimit":512,"AllowUrlfOpen":"enabled","UploadMaxFilesize":4,"PostMaxSize":8,"MaxExecutionTime":0,"MaxFileUploads":20,"lets_encrypt":false,"http2https":true,"Indexes":"enabled","status":"enabled"}'
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Check if vhost can be updated
    ${rc} =    Execute Command    api-cli run module/${module_id}/update-vhost --data '{"PhpVersion":"8.2","ServerNames":["foo.com","john.com"],"Port":9001,"MemoryLimit":512,"AllowUrlfOpen":"enabled","UploadMaxFilesize":4,"PostMaxSize":8,"MaxExecutionTime":0,"MaxFileUploads":20,"lets_encrypt":false,"http2https":true,"Indexes":"enabled","status":"enabled"}'
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Check if vhost can be destroyed
    ${rc} =    Execute Command    api-cli run module/${module_id}/destroy-vhost --data '{"ServerNames": ["foo.com","john.com"],"port": 9001}'
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0


Check if webserver is removed correctly
    ${rc} =    Execute Command    remove-module --no-preserve ${module_id}
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0