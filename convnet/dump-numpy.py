import argparse

import numpy

def chunk(thing, size):
    x = 0
    out = []
    for val in thing:
        out.append(val)
        x += 1
        if x % size == 0:
            yield out
            out = []
            x = 0
    if out:
        yield out
            

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--input')
    parser.add_argument('--rows', type=int, default=0, help='Reshape before printing')
    parser.add_argument('--cols', type=int, default=0, help='Reshape before printing')
    args = parser.parse_args()

    data = numpy.load(args.input)#, dtype=numpy.float32)
    if args.rows or args.cols:
        data = data.reshape(args.rows, args.cols)

    print(' '.join(str(x) for x in data.shape))

    for line in chunk(data.flatten(), 32):
        for v in line:
            print(v, end=" ")
        print()
