import argparse
import os
import shlex
import sys
import unittest

from frictionless import Resource, Schema, validate


class Test(unittest.TestCase):
    def test_cli(self):
        args = cli(f"tx --schema file.schema.yml input.csv -o output.csv")
        self.assertEqual("file.schema.yml", args.schema)
        self.assertEqual("input.csv", args.input)
        self.assertEqual("output.csv", args.output)

    def test_transform_by_schema(self):
        args = cli(f"tx --schema working_example/epiestim_estimate_r.input.schema.yaml working_example/epinow2_reported_cases.csv -o output.csv")
        transform_by_schema(args)
        with open("output.csv") as f:
            header = f.readline()
            print(header)
            self.assertEqual("dates,I", header.strip())
        os.remove("output.csv")


def cli(command):
    """Helper function to facilitate testing on CLI strings"""
    sys.argv = shlex.split(command)
    return parse_args()


def parse_args():
    parser = argparse.ArgumentParser(description="Transform data by schema")
    parser.add_argument("-s", "--schema", help="Path to the schema file")
    parser.add_argument("-T", "--transform", help="Path to a JSON file with the transform to apply")
    parser.add_argument("input", help="Path to the input file")
    parser.add_argument("-o", "--output", default=sys.stdout, help="Path to the output file [default: stdout]")
    return parser.parse_args()


def transform_by_schema(args):
    """Perform the actual transformation by schema"""
    schema = Schema.from_descriptor(args.schema)
    # validate the schema
    report = validate(schema)
    print(report)
    # read in the resource and transform
    resource = Resource(args.input, schema=schema)
    # print(resource)
    # print(resource.to_view(type="see"))
    resource.write(args.output)  # write to file


def main():
    args = parse_args()

    if args.output != sys.stdout:
        with open(args.output, 'w') as output_file:
            sys.stdout = output_file
            transform_by_schema(args)
    return os.EX_OK


if __name__ == '__main__':
    sys.exit(main())
