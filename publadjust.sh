#!/bin/bash

check_filetype() {
  mtype=$(file --mime-type -b "${1}")

  if ! echo $mtype | grep -q pdf
  then
    echo "Error: Provided file ist not a pdf!"
    echo "Script is aborted..."
    exit 1
  fi
  }

handle_filenames() {
  basic_filename="${1%.pdf}"
  temp_folder="${basic_filename}_publadjust"
}

create_temporary_folder() {
  mkdir "${temp_folder}"
}

delete_annotations() {

  handle_filenames ${1}

  echo "Pdf file ${1} is being uncompressed..."
  echo ""
  pdftk "${1}" output ".${basic_filename}_uc.pdf" uncompress

  echo "All annotations in the file are being deleted..."
  echo ""
  LANG=C sed -n '/^\/Annots/!p' ".${basic_filename}_uc.pdf" > ".${basic_filename}_uc_stripped.pdf"

  echo "Result is saved as ${basic_filename}_stripped.pdf."
  echo ""
  pdftk ".${basic_filename}_uc_stripped.pdf" output "${basic_filename}_stripped.pdf" compress

  echo "Temporary files are deleted."
  echo ""
  rm ".${basic_filename}_uc.pdf"
  rm ".${basic_filename}_uc_stripped.pdf"

  read -p "Do you want to delete the original pdf-file? (y/N): " confirm_del

  if [ "$confirm_del" == "y" ]

  	then
  		gio trash "${1}"
      echo ""
      echo "Original pdf ${1} is moved to trash."

  	else
      echo ""
  		echo "Original pdf ${1} is not deleted."

  fi

  echo ""
  echo "Done!"
  echo ""

  exit 0
}

# extract_from_collected_volume () {
#
# }

alter_page_labels () {
  # checking if python script is installed
  if ! pip list | tail -n +1 | grep -q pagelabels ; then
    echo "Error: \"pagelabels-py\" by lovasoa (cf. https://github.com/lovasoa/pagelabels-py) is not installed."
    echo "Script is aborted."
    exit 1
  fi

  # running script
  repeat=y
  while [ "$repeat" == "y" ]; do

  echo ""
  read -ep "Enter beginning of new pagination section (according to absolute page number of pdf): " secbegin
  echo ""

  echo "Optional: enter different style of pagination; leave empty for Arabic numerals or type"
  echo "(1) \"lr\" for lowercase roman numerals (i, ii, etc.),"
  echo "(2) \"ur\" for uppercase roman numerals (I, II, etc.),"
  echo "(3) \"ll\" for lowercase letters (a, b, etc.), or"
  read -ep "(4) \"ul\" for uppercase letters (A, B, etc.): " style
  case "$style" in
  	"") style="arabic";;
  	"lr") style="roman lowercase";;
  	"ur") style="roman uppercase";;
  	"ll") style="letter lowercase";;
  	"ul") style="letter uppercase";;
  esac
  echo ""

  read -ep "Optional: add prefix (e.g., \"fm\" for frontmatter): " prefix
  echo ""

  read -ep "Optional: enter different start of pagenumber (e.g., 3 instead of 1): " numbegin
  echo ""
  if ["$numbegin" == ""]; then numbegin=1; fi

  python3 -m pagelabels --startpage "$secbegin" --type "$style" --prefix "$prefix" --firstpagenum "$numbegin" "${1}"

  echo ""
  read -ep "Add/change another section for pagination? (y/N) " repeat

  done

  echo ""
  echo "Done!"
  echo ""

  exit 0
}

set_file_variables_for_odd_and_even () {
  beginning="${temp_folder}/${basic_filename}_pp-$(($1-1)).pdf"
  odd="${temp_folder}/${basic_filename}_pp${1}-${2}_odd.pdf"
  even="${temp_folder}/${basic_filename}_pp${1}-${2}_even.pdf"
  end="${temp_folder}/${basic_filename}_pp$(($2+1))-.pdf"
  }

split_odd_and_even () {

  check_filetype ${1}

  # prompt user to input page range
  read -e -p "Beginning of page range for extracting odd and even pages: " pstart
  read -e -p "End of page range for extracting odd and even pages: " pend

  handle_filenames ${1}
  create_temporary_folder

  set_file_variables_for_odd_and_even $pstart $pend

  # use pdftk to split pages
  pdftk "${1}" cat 1-"$((pstart-1))" output "${beginning}"
  pdftk "${1}" cat "$pstart"-"$pend"odd  output "${odd}"
  pdftk "${1}" cat "$pstart"-"$pend"even output "${even}"
  pdftk "${1}" cat "$((pend+1))"-end output "${end}"

  # use pdftk to dump all metadata
  pdftk "${1}" dump_data_utf8 output "${temp_folder}/.${basic_filename}_data"

  # write parameters to hidden files
  echo $pstart > "${temp_folder}/.${basic_filename}_sameopdfpstart"
  echo $pend > "${temp_folder}/.${basic_filename}_sameopdfpend"

  # echo result
  echo ""
  echo "The file ${1} was split and, in the new folder ${temp_folder}, files can be found with:"
  echo "(1) all pages up to, but not including page $pstart;"
  echo "(2) odd pages between pages $pstart and $pend;"
  echo "(3) even pages between pages $pstart and $pend;"
  echo "(4) all pages from, but not including page $pend to the end, respectively"
  echo ""
  echo "These files can now be processed independently and later be merged."

  exit 0
}

merge_odd_and_even () {

  handle_filenames ${1}

  # check if temporary folder exists
  if [ ! -d "${temp_folder}" ]
  then
      echo "Error: No folder with split files based on ${1} was found."
      echo "Have you used the script with the flag -s first?"
      exit 1
  fi

  # read parameters from hidden files
  read pstart < "${temp_folder}/.${basic_filename}_sameopdfpstart"
  read pend < "${temp_folder}/.${basic_filename}_sameopdfpend"

  set_file_variables_for_odd_and_even $pstart $pend

  # use pdftk to merge pages
  pdftk A="${odd}" B="${even}" shuffle A B output "${temp_folder}/.${basic_filename}_meo.pdf"

  pdftk "${beginning}" "${temp_folder}/.${basic_filename}_meo.pdf" "${end}" cat output "${temp_folder}/.${basic_filename}_merged_no-data.pdf"

  pdftk "${temp_folder}/.${basic_filename}_merged_no-data.pdf" update_info_utf8 "${temp_folder}/.${basic_filename}_data" output "${basic_filename}_merged.pdf"

  echo "Files were merged to ${basic_filename}_merged.pdf."

  # ask user if extracted files should be deleted
  echo ""
  read -e -p "Should all files based on ${1} in the folder ${temp_folder} be moved to the trash? (y/N): " delete
  if [ "$delete" == "y" ]
  then
    gio trash "${temp_folder}"
  fi

  exit 0
}

test_function() {
  echo "blabla"
}

while getopts 'd:p:s:m:t' opt; do

  case ${opt} in
    d)
    delete_annotations ${OPTARG}
    ;;
    p)
    alter_page_labels ${OPTARG}
    ;;
    s)
    split_odd_and_even ${OPTARG}
    ;;
    m)
    merge_odd_and_even ${OPTARG}
    ;;
    t)
    test_function
    ;;
  esac
done

exit 0
