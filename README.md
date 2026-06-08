Student Marklist COBOL Program

Overview
- A simple COBOL program to create a student marklist: reads student records, computes totals, percentages, and assigns grades.

Requirements
- GnuCOBOL (cobc) installed. On Windows, install GnuCOBOL via MSYS2 or native installer if available.

Files
- `src/marklist.cob`: The COBOL source.
- `tests/test_input.txt`: Sample input for tests.
- `tests/expected_output.txt`: Expected program output for the sample input.
- `run_tests.bat`: Windows batch script to compile and run tests.

Compile
Open a command prompt in the workspace root and run:

```
cobc -x -free src\marklist.cob -o marklist.exe
```

Run
To run interactively:

```
marklist.exe
```

To run with the provided test input and capture output:

```
marklist.exe < tests\test_input.txt > tests\actual_output.txt
```

Built-in tests
- You can run the built-in self-tests (no external files needed) by piping the word `TEST` to the program. On Windows:

```
echo TEST | marklist.exe
```

The program will report PASS/FAIL for each internal testcase.

Test
Use the included `run_tests.bat` on Windows to compile, run, and compare output:

```
run_tests.bat
```

Input Format
- First line: number of students (N)
- Next N lines: comma-separated values: `roll,name,m1,m2,m3,m4,m5`
- Example: `101,John Doe,78,82,69,74,88`

Notes
- `name` may contain spaces (e.g., "John Doe").
- The program expects exactly 5 marks per student.
# newlabtest