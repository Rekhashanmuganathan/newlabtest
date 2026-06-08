       identification division.
       program-id. MARKLIST.
       author. GitHub Copilot.

       environment division.

       data division.
       working-storage section.

       77 NUM-STUDENTS        pic 9(3) value 0.
       77 IDX                 pic 9(3) value 1.

       01 IN-LINE             pic x(200).
       01 F-ROLL              pic x(10).
       01 F-NAME              pic x(30).
       01 F-M1                pic x(5).
       01 F-M2                pic x(5).
       01 F-M3                pic x(5).
       01 F-M4                pic x(5).
       01 F-M5                pic x(5).

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

       01 PERCENT-DISP       pic 9(3).99.

       procedure division.
       main-logic.
           display "Enter number of students (e.g. 3) and then each student on a new line as:"
           display "roll,name,m1,m2,m3,m4,m5"
           accept in-line
           unstring in-line delimited by all spaces into f-ROLL
           if function numeric-value(f-ROLL) > 0
               compute num-students = function numeric-value(f-ROLL)
           else
               move 0 to num-students
           end-if

           perform varying idx from 1 by 1 until idx > num-students
               accept in-line
               if in-line = "" then
                   subtract 1 from idx
                   next sentence
               end-if
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

           perform display-marklist

           stop run.

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
