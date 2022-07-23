This program computes the digits of pi on the TRS-80 MC-10 with a 16K RAM expansion

To use it first CLOADM the .C10 file into your favorite emulator.

To compute and display the numbers, type EXEC:n
where n is the number of digits you want, up to 10,000.

It internally uses Fredrik Carl Mülertz Størmer's formula:
  Pi/4 = 6 arctan(1/8) + 2 arctan(1/57) + arctan(1/239)
