Documentation for Templates
===========================

Templates are made up of three parts - metadata, filters and exporter. At is most simplest, only the metadata field needs to be provided.

##Metadata
```json
  "metadata" : {
    "version" : "2022-04-02",
    "name" : "<name>",
    "description" : "<description>"
    "handler" : "<handler>"
  },...
```

###Keys
- **version**: API version, default is [2022-04-02]
- **name**: Name of the template.
- **description**: Description of the template.
- **handler**: Specifies the type of spreadsheet to process. Default is [AwsCur]

-------------------------------------------

##Filters
```json
  ...
  "filters":  {
    "condition": "<and/or>",
    "rules": [{
        "field": "<column_header>",
        "type": "<number|string>",
        "operator": "<operator>",
        "value": "<value>"
      }
    ]
  },...
```
###Keys
- **condition**: Must be either and/or. Can be nested.
- **rules**: List of rules
  - **field**: Field found in spreadsheet.
  - **type**: Data type, either string or number.
  - **operator**: Predicate to validate against - <equal, not_equal,..>.
  - **value**: Value to validate against.
  
  