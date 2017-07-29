import zipfile
import re
import os
import argparse


def main(dir, name_to_search):
    # Check all files in the directory and print the name of the package
    for root, dirs, files in os.walk(dir):
        wheels = (fname for fname in files if fname.endswith('whl'))
        for fname in wheels:
            filename = os.path.join(dir, fname)
            zfile = zipfile.ZipFile(filename)
            metadata = [file for file in zfile.infolist()
                        if file.filename.endswith('METADATA')][0]
            data = zfile.open(metadata.filename)
            name = [line.rstrip().decode('ascii')
                    for line in data.readlines() if b'Name' in line][0]
            # Extract the name
            name = re.match('Name: (?P<name>\S+)$', name).groupdict()['name']
            if name == name_to_search:
                print(filename)
                exit(0)

            # Check if the name replaces underscores with dashes
            # The wheel documentation is VERY confusing and inconsistent
            # about this
            if name.replace('_', '-') == name_to_search:
                print(filename)
                exit(0)

            if name.replace('-', '_') == name_to_search:
                print(filename)
                exit(0)

    print('Package {} not found'.format(name_to_search))
    exit(1)


if __name__ == '__main__':
    desc = 'Return the wheel that that contains the package name'
    parser = argparse.ArgumentParser(description=desc)
    parser.add_argument('-d', dest='dir',
                         help='directory to search')
    parser.add_argument('name', help='Name of the package to search')
    args = parser.parse_args()

    main(args.dir, args.name)
