@echo off
cd /d "C:\Users\sarah\Documents\GitHub\CBTA"
"C:\Program Files\Git\bin\git.exe" add .
"C:\Program Files\Git\bin\git.exe" commit -m "Fix Vercel 404 config"
"C:\Program Files\Git\bin\git.exe" push
pause
