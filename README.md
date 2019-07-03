# Programmability Evaluation Repository Instructions

0. Download your key file here: `<KEYFILE.pem>`

1. Follow the [Getting Started instructions](http://mitchell-lang.github.io/docs/getting-started.html) to connect to your virtual machine.

    Notes:
     - VMs may take a couple of minutes to start
     - If you get a warning about permissions, you may have to run `chmod 600
       <KEYFILE.pem>`
     - If you're using Windows, you may have to convert the key to `.ppk`

2. Navigate to `/data/test/{task}` according to the task you've been assigned.

    The `/data/test/{task}` directory contains a number of files:
    Each task consists of a directory structured as follows:

    ```
    ├── README.md ──────── documentation
    ├── docs ───────────── more documentation (figures, etc)
    │
    ├── install.sh ─────── `source` this to set up the environment for data
    │                      preprocessing and validation
    ├── Makefile ───────── Mitchell build script
    │                      Use `make` to build your program and `make evaluate`
    │                      to acquire data, build your program, run your program,
    │                      and validate the results.
    │
    ├── data ───────────── data (acquired and pre-processed by `make evalaute`)
    │
    ├── main.sml ───────── scaffolding (IO)
    ├── main.mlb ───────── scaffolding (project file)
    ├── {task}.sml ─────── implementation skeleton
    ├── {task}.sig ─────── implementation skeleton function signatures
    └── validate.py ────── validation script
    ```

    You should start by reading the `README.md` and any associated materials.

    __The testers' task is to write a functional `main.sml` that passes the
    correctness check in `validate.py`__.  `main.sml` contains the IO
    scaffolding and specifies all of the necessary parameters given to the
    implementation skeleton in `{task}.sml`, which should be filled out by the
    testers.

    You do not have to run `prep.py` or other data preparation scripts by hand.
    `make evaluate` will acquire and pre-process the data, which can be found
    in the `data` directory.

    Note that the `validate.py` (used by `make evaluate`) and the data
    preparation scripts require that you run `source install.sh` to set up the
    required Python environment.

3. Implement the algorithm! Use the `Makefile` targets as described
[here](https://mitchell-lang.github.io/docs/getting-started.html#running-mitchell-programs-for-the-assigned-workloads)
to build your program and validate your results.

4. __Important__  When you are done: your program __must write your results to
   the location that the given `main.sml` uses__ and they __must pass the
   correctness check performed by `make evaluate`__ or your submission will be
   considered incomplete. If you do not modify `main.sml` this will be the
   case.

__If you have bug reports / concerns / suggestions regarding this repo, please
open an issue.  We're looking for feedback to make sure that the tasks are well
specified and clearly explained.__
