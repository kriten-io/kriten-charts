# Kriten Example

## Table of Content

- [Kriten Example](#kriten-example)
  - [Table of Content](#table-of-content)
  - [Kriten connection details](#kriten-connection-details)
  - [Example of running Python script with Kriten](#example-of-running-python-script-with-kriten)
    - [Login into Kriten](#login-into-kriten)
    - [Create Runner](#create-runner)
    - [Create Task](#create-task)
    - [Run Job](#run-job)
    - [Get Job result](#get-job-result)

## Kriten connection details

Below are connection details to the Kriten system referenced here:

|Parameter|Value|Comment
|---------|-----------|-------|
|`base_url`|http://kriten.kriten.192.168.10.102.nip.io|
|`username`|root|Admin user
|`password`|root|Admin user password
|`provider`|local|Local Authenticator

Swagger UI is available at address `base_url/swagger/index.html`, i.e. http://kriten.kriten.192.168.10.102.nip.io/swagger/index.html.

## Example of running Python script with Kriten

There is a simple python script, which demonstrates access to input variables and secrets, provided by Kriten to the Job container, where the script is executed.

```
import os
import json
from pprint import pprint

secrets_path = '/etc/secret/'

print('Hello, Kriten!\n')

# Kriten exposes input variables for the Job as env variable 'EXTRA_VARS' in json format
# Following code reads it and prints out content

extra_vars = os.environ.get('EXTRA_VARS')

if extra_vars:
    extra_vars_data = json.loads(extra_vars)
    pprint('Extra vars:')
    pprint(extra_vars_data)

else:
    print("No extra vars provided.")


# Kriten exposes task secrets to the Job container as files stored in /etc/secret/ directory.
# Following code reads those files and prints in format 'filename:content'

secret_files = os.listdir(secrets_path)
print(secret_files)
if secret_files:
    print('Revealing secrets, which are no longer secret!\n')
    for file_name in secret_files:
        if os.path.isfile(secrets_path + file_name):
            with open(secrets_path + file_name, 'r') as f:
                value = f.read()
                print(f'{file_name}:{value}')

else:
    print("No task secrets provided.")

print('Script complete.')
```

Above python script is published in Public Git repo: https://github.com/Kriten-io/kriten-python-example.git and we will be using "python:3.9-slim" container image.


### Login into Kriten

>`POST {{base_url}}/api/v1/login`

Request body parameters:

|Name|Description|Type|Required|Example
|---------|-----------|-------|-------|--------|
|`username`|Username|`string`|true|root
|`password`|Password|`string`|true|root
|`provider`|Authentication Provider (local or active_directory)|`string`|true|local

Executing example with cURL:

```
$ curl -c ./token.txt --location 'http://kriten.kriten.192.168.10.102.nip.io/api/v1/login' \
--header 'Content-Type: application/json' \
--data '{
    "username": "root",
    "password": "root",
    "provider": "local"
}'

```
Note: Authentication token is stored by cURL in ./token.txt file and used in subsequent examples.

### Create Runner

>`POST {{base_url}}/api/v1/runners/`

Request body parameters:

|Name|Description|Type|Required|Example
|---------|-----------|-------|-------|--------|
|`gitURL`|URL to git repository|`string`|true|https://github.com/Kriten-io/kriten-python-example.git
|`token`|Access token or password for git repo if not public|`string`|true|""
|`id`|Unique runner name|`string`|true|kriten-python-runner
|`image`|Container image with required tools and packages|`string`|true|python:3.9-slim

Executing example with cURL:

```
$ curl -b ./token.txt --location 'http://kriten.kriten.192.168.10.102.nip.io/api/v1/runners/' \
--header 'Content-Type: application/json' \
--data '{
        "gitURL": "https://github.com/Kriten-io/kriten-python-example.git",
        "id": "kriten-python-runner",
        "image": "python:3.9-slim"
    }'

```

### Create Task

>`POST {{base_url}}/api/v1/tasks`

Request body parameters:

|Name|Description|Type|Required|Example
|---------|-----------|-------|-------|--------|
|`command`|Command to run in the container|`string`|true|python hello-user.py
|`id`|Unique task name|`string`|true|hello-kriten
|`runner`|Associated runner name|`string`|true|kriten-python-runner
|`synchronous`|Synchronous job execution|`boolean`|false|false
|`secret`|(*) Secrets supplied as key/value pairs|`map of string`|false|{"username":"admin", "password":"P@55w0rd!", "super_secret": "1234567890!"}

* Secrets supplied as key:value pairs, will be stored as Kubernetes secrets and exposed to Job container as files in mounted /etc/secret/ directory.

Executing example with cURL:

```
$ curl -b ./token.txt --location 'http://kriten.kriten.192.168.10.102.nip.io/api/v1/tasks' \
--header 'Content-Type: application/json' \
--data-raw '{
        "command": "python hello-kriten.py",
        "id": "hello-kriten",
        "runner": "kriten-python-runner",
        "synchronous": false,
        "secret": {
            "username": "admin",
            "password": "P@55w0rd!",
            "super_secret": "1234567890!"
        }
}'
```

### Run Job

>`POST {{base_url}}/api/v1/jobs/{{task_name}}`

Request body parameters:

|Name|Description|Type|Required|Example
|---------|-----------|-------|-------|--------|
| |Import parameters exposed as EXTRA_VARS env var to the Job containers |`json string`|false|'{"name":"Ethan Hunt", "operation":"Mission impossible"}'

Executing example with cURL:

```
$ curl -b ./token.txt --location 'http://kriten.kriten.192.168.10.102.nip.io/api/v1/jobs/hello-kriten/' \
--header 'Content-Type: application/json' \
--data '{
    "name": "Ethan Hunt",
    "operation":"Mission impossible"
}'

```
Response for asynchronous jobs if successful will return Job ID, i.e. "hello-user-ks67g" as below.

```
{
    "msg": "job executed successfully",
    "value": "hello-user-ks67g"
}
```

### Get Job result

>`GET {{base_url}}/api/v1/jobs/{{job_id}}`

Example with curl for the job_id 'hello-user-ks67g':

```
$ curl -X GET -b ./token.txt --location 'http://kriten.kriten.192.168.10.102.nip.io/api/v1/jobs/hello-user-ks67g' \
--data ''
```
Response:

```
Hello, Kriten!

Extra vars:
{'name': 'Ethan Hunt', 'operation': 'Mission impossible'}

Revealing secrets, which are no longer secret!
username:admin
super_secret:1234567890!
password:P@55w0rd!

Script complete.
```





