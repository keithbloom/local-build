FOR /L %%A IN (1, 1, 58) DO (
gswin32c.exe -sDEVICE=jpeg -r200 -o %client1%_jpgs/%client1%_Category1-%%A_%%d.jpg %client1%\%client1%_Category1-%%A.pdf
)