@echo off
rem Compile COBOL source with GnuCOBOL
cobc -x -free src\marklist.cob -o marklist.exe
if %errorlevel% neq 0 (
    echo Compilation failed.
    exit /b %errorlevel%
)

rem Run program with test input and capture output
marklist.exe < tests\test_input.txt > tests\actual_output.txt

rem Compare actual output to expected
fc tests\expected_output.txt tests\actual_output.txt
if %errorlevel% equ 0 (
    echo TESTS PASSED
) else (
    echo TESTS FAILED
    exit /b 1
)
