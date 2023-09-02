rem this bat file should be run from a Visual Studio Developer Command Prompt
rem see: https://docs.microsoft.com/en-us/cpp/build/walkthrough-compile-a-c-program-on-the-command-line
rem
rem If the link is stale, try searching the internet for "Walkthrough: Compile a C program on the command line"
rem

if not exist .build\ mkdir .build
cl /I. /EHsc /Fo.build\ tasm\*.cpp main\*.cpp utils\*.cpp /link /out:tasm6801.exe
