Pal
===

Pal is a tool for automating simple cloud spend analysis. It provides just enough features to be useful.
- **Analysis as Code** [*In Progress*]: Describe simple routines to extract, filter and manipulate data from cloud provider spreadsheets.
  - Export data into common data formats for further analysis or visualisation in a different tool.
  - Examples of this are provided in our templates folder.
- **Forecasting** [*To Do*]: Pipe data from your results into common forecasting algorithms.

## Use Cases

Common use cases are:
- Analyse data using a "write once, run many times" templating approach [see examples below]. 
- Automate the break down of large and unwieldy provider spreadsheets into more digestable and "Excel friendly" files.

## Usage

Two things are needed to run Pal, the cloud provider spreadsheet and the template file. Optionally, you can provide an output directory, otherwise it will use ``/tmp/pal``.

Provide these to Pal as arguments as follows: 

    $ pal -t /file/path/to/template.json -i /file/path/to/billing_file.csv -o /my/output/folder

## Example

Below shows the template and export from a simple request. 

It shows grouping all records from an AWS Cost and Usage Report by product and usage type, summing blended cost fields.

#### Template
```json
{
  ...
  "filters":  {
    "condition": "AND",
    "rules": [{
        "field": "lineItem/BlendedCost",
        "type": "number",
        "operator": "greater",
        "value": 0
      }
    ]
  },
  "exporter" : {
    "types" : [{
      "name" : "table",
      ...
    }],
    "properties" : [
      "lineItem/ProductCode",
      "lineItem/UsageType",
      "lineItem/BlendedCost"
    ],
    "actions" : {
      "group_by" : ["lineItem/ProductCode", "lineItem/UsageType"],
      "sort_by" : "sum_lineItem/BlendedCost",
      "projection" : {
        "type" : "sum",
        "property" : "lineItem/BlendedCost"
      }
    }
  }
}
```
*Find full template [here](templates/global_resource_and_usage_type_costs.json)*.

#### Exported
```bash
+------------------------------------------------------------------------------------+
|                     AWS CUR Product/Usage Type Combined Costs                      |
+----------------------+----------------------------------+--------------------------+
| lineItem/ProductCode | lineItem/UsageType               | sum_lineItem/BlendedCost |
+----------------------+----------------------------------+--------------------------+
| AmazonEC2            | APS2-EBS:VolumeUsage.gp2         | 48.80                    |
| AmazonRDS            | APS2-RDS:ChargedBackupUsage      | 8.12                     |
| AmazonEC2            | APS2-ElasticIP:IdleAddress       | 6.71                     |
| AmazonEC2            | APS2-EBS:SnapshotUsage           | 5.64                     |
...
```

Understand more about how templates work by clicking [here](templates/DOCUMENTATION.md).

## Installation

Install it yourself as:

    $ gem install pal

If you wish to use Docker, please use the Dockerfile provided.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/william-inf/pal. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/pal/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Pal project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/pal/blob/master/CODE_OF_CONDUCT.md).
