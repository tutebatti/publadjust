# publadjust
This shell script for Linux facilitates the adjustment of academic publications in form of pdfs.

The different features of the script are based on and require:
* pdftk (https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/)
* pagelabels-py (https://github.com/lovasoa/pagelabels-py)

Thanks!

There are several functions which the script can be started with.
It then leads the user through an interactive text based menu in the terminal.

### Split and Merge for independent processing of odd and even pages

The script is able to split pdf files into four files:
1. all pages up to page x,
2. odd pages between pages x and y,
3. even pages between pages x and y,
4. all pages from page y to end.

These files are moved to the folder named `#_publadjust`, where `#` is the original file name of the pdf.

Later, the files can be merged.

This is useful when processing a scanned book, where original and translation are on opposite pages:
the pages extracted can be processed independently and can then be merged again.

Metadata, including bookmarks and annotations, is exported from old file and imported in new file.
If errors occur, check the file `.#_data` in the temporary folder.

The folder or the files created by the script should not be moved or renamed.

Usage: `publadjust -flag file`, where
- `file` is a pdf file
- `flag` is either `s` for splitting or `m` for merging

### Delete annotations
Delete all annotations from a pdf file (e.g., before sharing).

Uses this gist: https://gist.github.com/stefanschmidt/5248592 – thanks!

Usage: `publadjust -d file.pdf`

### Relabel pages
Should be especially helpful with scanned books.

Usage: `publadjust -p file.pdf`

### Extract contributions from edited volumes
For handling contributions to edited volumes separately.

Usage: `publadjust -e file.pdf`

The resulting pdf files are saved to the folder named `#_publadjust`, where `#` is the original file name of the pdf.

### To do

- improve documentation/README.md
