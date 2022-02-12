# publadjust
This shell script for Linux facilitates the adjustment of publications in form of pdfs.

The different features of the script are based on and require installation of:
* pdftk (https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/)
* pagelabels-py (https://github.com/lovasoa/pagelabels-py)

There are several functions which the script can be started with. It then leads the user through an interactive text based menu in the terminal.

### Split and Merge for independent processing odd and even pages

The script is able to split pdf files into four files:
1. all pages up to page x,
2. odd pages between pages x and y,
3. even pages between pages x and y,
4. all pages from page y to end.

These files are moved to folder named #_sameopdf, where # is the original file name of the pdf.

Later, the files can be merged.

This is useful when processing a scanned book, where original and translation are on opposite pages: The pages extracted can be processed independently and can then be merged again.

The folder or the files created by the script should not be moved or renamed.

Usage: `sameopdf -flag file`, where
- `file` is a pdf file
- `flag` is either `s` for splitting or `m` for merging

### delnot-pdf
Simple bash script to delete all annotations from a pdf file (e.g., before sharing).

Based on and requires pdftk (https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/).

Usage: `delnot-pdf file.pdf`

### pag-pdf
Bash script to facilitate changing internal pagination of pdf-file.

Based on and requires pagelabels-py (https://github.com/lovasoa/pagelabels-py).

Provides a text based user interface and should be especially helpful with scanned books.

Usage: `pag-pdf file.pdf`
