# todo.R -- convert a spreadsheet of dates into a todo list

Given a comma-separated values (CSV) file with columns for project_name, plus arbitrary pairs of MILESTONE_date and MILESTONE_done, this script creates a to-do list of upcoming 'milestones'.

In other words, this:

| project_name | start_date | start_done | presentation_date | presentation_done | project_close_date | project_close_done |
|:------------:|:----------:|:----------:|:-----------------:|:-----------------:|:------------------:|:-------------------------:|
|  Project_A   | 2022-10-08 |    TRUE    |    2022-10-13     |       TRUE        | 2022-10-20 | TRUE |
|  Project_B   | 2022-10-09 |    TRUE    |    2022-10-14     |       TRUE        | 2022-10-21 | FALSE |
|  Project_C   | 2022-10-10 |    TRUE    |    2022-10-15     |       FALSE       | 2022-10-22 | FALSE |
|  Project_D   | 2022-10-11 |   FALSE    |    2022-10-16     |       FALSE       | 2022-10-23 | FALSE |
|  Project_E   | 2022-10-12 |   FALSE    |    2022-10-17     |       FALSE       | 2022-10-24 | FALSE |

becomes this:

| due_date | remaining | project_name | milestone | 
|:------------:|:----------:|:----------:|:-----------------:|
|  2022-10-11   | 4 days | Project_D  | start |
|  2022-10-12   | 5 days | Project_E  | start |
|  2022-10-15   | 8 days | Project_C  | presentation |
|  2022-10-16   | 9 days | Project_D  | presentation |
|  2022-10-17   | 10 days | Project_E | presentation |
|  2022-10-21   | 14 days | Project_B | project close |
|  2022-10-22   | 15 days | Project_C | project close |
|  2022-10-23   | 16 days | Project_D | project close |
|  2022-10-24   | 17 days | Project_E | project close |

**Note** that this script requires that `MILESTONE` is identical between `MILESTONE_date` and `MILESTONE_done`. In other words, this will work: `presentation_date`/`presentation_done`. But this will not: `presentation_date`/`Presentation_done`. 

# Usage

1.  Download this Git repository
2.  By default, the script assumes dates will be given in the format "YYYY-MM-DD". If you use another format, eg "MM/DD/YYYY", use a plain-text editor (eg, Windows Notepad or macOS TextEdit) to indicate that on line 17.
3.  At the command line, navigate to the directory where you downloaded this script and execute `Rscript todo.R` (macOS) or `Rscript.exe todo.R` (Windows).

# License

Copyright 2021 Jeffrey M. Perkel

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
3.  Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
