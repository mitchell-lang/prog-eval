import argparse

import numpy

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--input')
    parser.add_argument('--rows', type=int, default=0, help='Reshape before printing')
    parser.add_argument('--cols', type=int, default=0, help='Reshape before printing')
    args = parser.parse_args()

    data = numpy.fromfile(args.input, dtype=numpy.float32)
    if args.rows or args.cols:
        data = data.reshape(args.rows, args.cols)

    print(data.shape[0], data.shape[1])
    for r in range(data.shape[0]):
        for val in data[r]:
            print(val, end=" ")
        print()
        
