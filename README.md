# Rack::Spec
[JSON Schema](http://json-schema.org/) based Rack middlewares.

## Usage
```ruby
str = File.read("schema.json")
schema = JSON.parse(str)

use Rack::Spec::ErrorHandler
use Rack::Spec::RequestValidation, schema: schema
use Rack::Spec::ResponseValidation, schema: schema if ENV["RACK_ENV"] == "test"
use Rack::Spec::Mock, schema: schema if ENV["RACK_ENV"] == "mock"
```

### Example
```sh
$ curl http://localhost:9292/recipes
{"id":"link_not_found","message":"Not found"}

$ curl http://localhost:9292/apps -H "Content-Type: application/json" -d "invalid-json"
{"id":"invalid_json","message":"Request body wasn't valid JSON"}

$ curl http://localhost:9292/apps -H "Content-Type: text/plain" -d "{}"
{"id":"invalid_content_type","message":"Invalid content type"}

$ curl http://localhost:9292/apps -H "Content-Type: application/json" -d '{"name":"x"}'
{"id":"invalid_parameter","message":"Invalid request.\n#/name: failed schema #/definitions/app/links/0/schema/properties/name: Expected string to match pattern \"/^[a-z][a-z0-9-]{3,50}$/\", value was: x."}
```

### Rack::Spec::RequestValidation
Validates request and raises errors below.

* Rack::Spec::RequestValidation::InvalidContentType
* Rack::Spec::RequestValidation::InvalidJson
* Rack::Spec::RequestValidation::InvalidParameter
* Rack::Spec::RequestValidation::LinkNotFound

### Rack::Spec::ResponseValidation
Validates request and raises errors below.
This middleware would be used for testing response type in test env or CI.

* Rack::Spec::RequestValidation::InvalidResponseContentType
* Rack::Spec::RequestValidation::InvalidResponseType

### Rack::Spec::Mock
Generates dummy response by using example property in JSON schema.

```
$ curl http://localhost:9292/apps/1
[
  {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "example"
  }
]

$ curl http://localhost:9292/apps/01234567-89ab-cdef-0123-456789abcdef
{
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "name": "example"
}

$ curl http://localhost:9292/apps/1 -d '{"name":"example"}'
{
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "name": "example"
}

$ curl http://localhost:9292/recipes
{"id":"example_not_found","message":"No example found for #/definitions/recipe/id"}
```

### Rack::Spec::ErrorHandler
Returns appropriate error response including following properties when RequestValidation raises error.

* message: Human readable message
* id: Error type identifier listed below
 * invalid_content_type
 * invalid_json
 * invalid_parameter
 * invalid_response_content_type
 * invalid_response_type
 * link_not_found

### Errors
```
StandardError
|
Rack::Spec::Error
|
|--Rack::Spec::Mock::Error
|  |
|  `--Rack::Spec::RequestValidation::ExampleNotFound
|
|--Rack::Spec::RequestValidation::Error
|  |
|  |--Rack::Spec::RequestValidation::InvalidContentType
|  |
|  |--Rack::Spec::RequestValidation::InvalidJson
|  |
|  |--Rack::Spec::RequestValidation::InvalidParameter
|  |
|  `--Rack::Spec::RequestValidation::LinkNotFound
|
`--Rack::Spec::ResponseValidation::Error
   |
   |--Rack::Spec::ResponseValidation::InvalidResponseContentType
   |
   `--Rack::Spec::ResponseValidation::InvalidResponseType
```
