    *> ------------------------------------------------------------
    *> Student Marklist Program
    *> - Reads student records (roll,name,m1..m5), computes total,
    *>   percentage and assigns grade (A/B/C/D/F).
    *> - Supports an interactive mode and a built-in TEST mode.
    *> - Written as an educational example with inline tests.
    *> ------------------------------------------------------------
    identification division.
    program-id. MARKLIST.
    author. GitHub Copilot.

       *> Environment division: file-control for simple file operations
       *> This program supports a `FILE` mode that reads from a static
       *> `input.txt` and writes the marklist to `output.txt` in the
       *> current directory.
       environment division.
       input-output section.
       file-control.
           select in-file assign to "input.txt".
           select out-file assign to "output.txt".

    *> Data division: declarations for variables and tables used
    *> throughout the program.
    data division.
    working-storage section.

    *> NUM-STUDENTS: number of student records to read
    77 NUM-STUDENTS        pic 9(3) value 0.
    *> IDX: loop index used for iterating arrays and records
    77 IDX                 pic 9(3) value 1.
    *> TEST-MODE: flag set when running built-in self-tests
    77 TEST-MODE           pic x value 'N'.

    *> IN-LINE and F-*: temporary fields for reading and parsing
    *> a single input line. `IN-LINE` holds the raw input; fields
    *> F-ROLL..F-M5 hold the unconverted text parts after UNSTRING.
    01 IN-LINE             pic x(200).
    01 F-ROLL              pic x(10).
    01 F-NAME              pic x(30).
    01 F-M1                pic x(5).
    01 F-M2                pic x(5).
    01 F-M3                pic x(5).
    01 F-M4                pic x(5).
    01 F-M5                pic x(5).

         *> Tables to store parsed student data in memory. Using
         *> fixed-size occurrences for simplicity (max 100 students).
         01 ROLL-TABLE.
             05 ROLL-ENTRIES     occurs 100 times pic 9(5) value 0.
         01 NAME-TABLE.
             05 NAME-ENTRIES     occurs 100 times pic x(30) value spaces.
         01 M1-TABLE.
             05 M1-ENTRIES       occurs 100 times pic 9(3) value 0.
         01 M2-TABLE.
             05 M2-ENTRIES       occurs 100 times pic 9(3) value 0.
         01 M3-TABLE.
             05 M3-ENTRIES       occurs 100 times pic 9(3) value 0.
         01 M4-TABLE.
             05 M4-ENTRIES       occurs 100 times pic 9(3) value 0.
         01 M5-TABLE.
             05 M5-ENTRIES       occurs 100 times pic 9(3) value 0.
         01 TOTAL-TABLE.
             05 TOTAL-ENTRIES    occurs 100 times pic 9(4) value 0.
         01 PERCENT-TABLE.
             05 PERCENT-ENTRIES  occurs 100 times pic 9(3)v99 value 0.
         01 GRADE-TABLE.
             05 GRADE-ENTRIES    occurs 100 times pic x(2) value spaces.

    *> PERCENT-DISP: temporary numeric field used when formatting
    *> and comparing percentage values for display and tests.
    01 PERCENT-DISP       pic 9(3).99.

         *> Built-in test tables: used only when TEST mode is invoked.
         *> These hold small example records and expected grades for
         *> automated verification of the grading logic.
         77 TEST-COUNT          pic 9(3) value 0.
         01 TEST-ROLLS.
             05 TEST-ROLL-ENTRIES occurs 10 times pic 9(5) value 0.
         01 TEST-NAMES.
             05 TEST-NAME-ENTRIES occurs 10 times pic x(30) value spaces.
         01 TEST-M1-TABLE.
             05 TEST-M1-ENTRIES   occurs 10 times pic 9(3) value 0.
         01 TEST-M2-TABLE.
             05 TEST-M2-ENTRIES   occurs 10 times pic 9(3) value 0.
         01 TEST-M3-TABLE.
             05 TEST-M3-ENTRIES   occurs 10 times pic 9(3) value 0.
         01 TEST-M4-TABLE.
             05 TEST-M4-ENTRIES   occurs 10 times pic 9(3) value 0.
         01 TEST-M5-TABLE.
             05 TEST-M5-ENTRIES   occurs 10 times pic 9(3) value 0.
         01 TEST-EXPECTED-GRADE.
             05 TEST-GRADE-ENTRIES occurs 10 times pic x(2) value spaces.
         01 ACT-TOTAL           pic 9(4) value 0.

        *> File section: records used to read from and write to files
        file section.
        fd in-file.
        01 IN-FILE-REC        pic x(200).

        fd out-file.
        01 OUT-FILE-REC       pic x(200).

        77 FILE-STATUS        pic xx value spaces.

       *> Procedure division: program logic is organized into
       *> clearly named paragraphs. `main-logic` handles input,
       *> parsing, calculation and dispatch to display routines.
       procedure division.
       main-logic.
           *> Prompt user for number of students or the special
           *> keyword `TEST` to run built-in automated tests.
           display "Enter number of students (e.g. 3) and then each student on a new line as:"
           display "roll,name,m1,m2,m3,m4,m5"
           accept in-line
           *> If the user types TEST (case-insensitive), switch to
           *> test mode and run the self-tests without further input.
           if function upper-case(in-line) = "TEST" then
               move 'Y' to test-mode
               perform run-self-tests
               stop run
           end-if
           *> If user types FILE (case-insensitive) we operate in file
           *> mode: read from input.txt and write output to output.txt.
           if function upper-case(in-line) = "FILE" then
               display "Running in FILE mode: reading input.txt, writing output.txt"
               open input in-file
               if file-status = "00" then
                   read in-file into in-line at end
                       display "Input file is empty or missing first line." 
                       close in-file
                       stop run
                   end-read
                   *> first line should contain number of students
                   unstring in-line delimited by all spaces into f-roll
                   if function numeric-value(f-roll) > 0
                       compute num-students = function numeric-value(f-roll)
                   else
                       move 0 to num-students
                   end-if
                   open output out-file
                   perform varying idx from 1 by 1 until idx > num-students
                       read in-file into in-line at end
                           display "Unexpected end of input file." 
                           close in-file
                           close out-file
                           stop run
                       end-read
                       unstring in-line delimited by ","
                           into f-roll f-name f-m1 f-m2 f-m3 f-m4 f-m5
                       move function numval(f-roll) to roll-entries (idx)
                       move f-name to name-entries (idx)
                       move function numval(f-m1) to m1-entries (idx)
                       move function numval(f-m2) to m2-entries (idx)
                       move function numval(f-m3) to m3-entries (idx)
                       move function numval(f-m4) to m4-entries (idx)
                       move function numval(f-m5) to m5-entries (idx)
                       compute total-entries (idx) = m1-entries (idx) + m2-entries (idx) + m3-entries (idx) + m4-entries (idx) + m5-entries (idx)
                       compute percent-entries (idx) = total-entries (idx) / 5
                       if percent-entries (idx) >= 75 then
                           move "A" to grade-entries (idx)
                       else if percent-entries (idx) >= 60 then
                           move "B" to grade-entries (idx)
                       else if percent-entries (idx) >= 50 then
                           move "C" to grade-entries (idx)
                       else if percent-entries (idx) >= 40 then
                           move "D" to grade-entries (idx)
                       else
                           move "F" to grade-entries (idx)
                       end-if
                   end-perform
                   *> Write header and records to output file
                   move "------------------------------------------------------------" to OUT-FILE-REC
                   write OUT-FILE-REC
                   move "                          STUDENT MARKLIST                    " to OUT-FILE-REC
                   write OUT-FILE-REC
                   move "------------------------------------------------------------" to OUT-FILE-REC
                   write OUT-FILE-REC
                   move "Roll   Name                          M1  M2  M3  M4  M5  Total  Percent  Grade" to OUT-FILE-REC
                   write OUT-FILE-REC
                   move "----   ---------------------------  --- --- --- --- ---  -----  -------  -----" to OUT-FILE-REC
                   write OUT-FILE-REC
                   perform varying idx from 1 by 1 until idx > num-students
                       move percent-entries (idx) to percent-disp
                       string roll-entries (idx) delimited by size
                              " " delimited by size
                              name-entries (idx) delimited by size
                              " " delimited by size
                              m1-entries (idx) delimited by size
                              "," delimited by size
                              m2-entries (idx) delimited by size
                              "," delimited by size
                              m3-entries (idx) delimited by size
                              "," delimited by size
                              m4-entries (idx) delimited by size
                              "," delimited by size
                              m5-entries (idx) delimited by size
                              "," delimited by size
                              total-entries (idx) delimited by size
                              "," delimited by size
                              percent-disp delimited by size
                              " " delimited by size
                              grade-entries (idx) delimited by size
                              into OUT-FILE-REC
                       write OUT-FILE-REC
                   end-perform
                   move "------------------------------------------------------------" to OUT-FILE-REC
                   write OUT-FILE-REC
                   close in-file
                   close out-file
                   display "Wrote marklist to output.txt"
                   stop run
               else
                   display "Unable to open input.txt"
                   stop run
               end-if
           end-if
           unstring in-line delimited by all spaces into f-ROLL
           if function numeric-value(f-ROLL) > 0
               compute num-students = function numeric-value(f-ROLL)
           else
               move 0 to num-students
           end-if

           *> Read `num-students` lines, parse CSV values and store
           *> them into occurrence tables. Empty lines are skipped.
           perform varying idx from 1 by 1 until idx > num-students
               accept in-line
               if in-line = "" then
                   subtract 1 from idx
                   next sentence
               end-if
               *> Split the CSV input into fields
               unstring in-line delimited by ","
                   into f-roll f-name f-m1 f-m2 f-m3 f-m4 f-m5
               
               *> Convert textual fields into numeric storage arrays
               move function numval(f-roll) to roll-entries (idx)
               move f-name to name-entries (idx)
               move function numval(f-m1) to m1-entries (idx)
               move function numval(f-m2) to m2-entries (idx)
               move function numval(f-m3) to m3-entries (idx)
               move function numval(f-m4) to m4-entries (idx)
               move function numval(f-m5) to m5-entries (idx)

               *> Compute total and average (percentage) for the record
               compute total-entries (idx) = m1-entries (idx) + m2-entries (idx) + m3-entries (idx) + m4-entries (idx) + m5-entries (idx)
               compute percent-entries (idx) = total-entries (idx) / 5

               *> Determine grade from percentage thresholds
               if percent-entries (idx) >= 75 then
                   move "A" to grade-entries (idx)
               else if percent-entries (idx) >= 60 then
                   move "B" to grade-entries (idx)
               else if percent-entries (idx) >= 50 then
                   move "C" to grade-entries (idx)
               else if percent-entries (idx) >= 40 then
                   move "D" to grade-entries (idx)
               else
                   move "F" to grade-entries (idx)
               end-if
           end-perform

           perform display-marklist

           stop run.

       *> `run-self-tests` paragraph: populates small test dataset,
       *> computes grades using the same logic as `main-logic`, and
       *> compares results against expected grades to report PASS/FAIL.
       run-self-tests.
           *> Prepare 3 built-in test cases
           move 3 to test-count
           move 101 to test-roll-entries (1)
           move "John Doe" to test-name-entries (1)
           move 78 to test-m1-entries (1)
           move 82 to test-m2-entries (1)
           move 69 to test-m3-entries (1)
           move 74 to test-m4-entries (1)
           move 88 to test-m5-entries (1)
           move "A" to test-grade-entries (1)

           move 102 to test-roll-entries (2)
           move "Jane Smith" to test-name-entries (2)
           move 92 to test-m1-entries (2)
           move 85 to test-m2-entries (2)
           move 90 to test-m3-entries (2)
           move 95 to test-m4-entries (2)
           move 88 to test-m5-entries (2)
           move "A" to test-grade-entries (2)

           move 103 to test-roll-entries (3)
           move "Bob Brown" to test-name-entries (3)
           move 45 to test-m1-entries (3)
           move 55 to test-m2-entries (3)
           move 40 to test-m3-entries (3)
           move 35 to test-m4-entries (3)
           move 50 to test-m5-entries (3)
           move "D" to test-grade-entries (3)

           display "Running built-in tests..."
           perform varying idx from 1 by 1 until idx > test-count
               compute act-total = test-m1-entries (idx) + test-m2-entries (idx) + test-m3-entries (idx) + test-m4-entries (idx) + test-m5-entries (idx)
               compute percent-disp = act-total / 5
               if percent-disp >= 75 then
                   move "A" to act-grade-entries (idx)
               else if percent-disp >= 60 then
                   move "B" to act-grade-entries (idx)
               else if percent-disp >= 50 then
                   move "C" to act-grade-entries (idx)
               else if percent-disp >= 40 then
                   move "D" to act-grade-entries (idx)
               else
                   move "F" to act-grade-entries (idx)
               end-if

               if act-grade-entries (idx) = test-grade-entries (idx) then
                   display "Test " idx ": PASS - " test-name-entries (idx) " expected=" test-grade-entries (idx) " got=" act-grade-entries (idx)
               else
                   display "Test " idx ": FAIL - " test-name-entries (idx) " expected=" test-grade-entries (idx) " got=" act-grade-entries (idx)
               end-if
           end-perform
           display "Built-in tests completed."
           exit.

       display-marklist.
           display "------------------------------------------------------------"
           display "                          STUDENT MARKLIST                    "
           display "------------------------------------------------------------"
           display "Roll   Name                          M1  M2  M3  M4  M5  Total  Percent  Grade"
           display "----   ---------------------------  --- --- --- --- ---  -----  -------  -----"
           perform varying idx from 1 by 1 until idx > num-students
               move percent-entries (idx) to percent-disp
               display roll-entries (idx) space name-entries (idx) space
                       m1-entries (idx) "," m2-entries (idx) "," m3-entries (idx) "," m4-entries (idx) "," m5-entries (idx) "," total-entries (idx) "," percent-disp " " grade-entries (idx)
           end-perform
           display "------------------------------------------------------------"
           exit.
