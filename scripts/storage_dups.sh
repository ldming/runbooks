#!/bin/bash

# To be used to find duplicate repositories on our gitaly fleet.
#
# We do not check for repos that have no DB entry. For this use
# storage_audit.rb

NR_FILESERVERS=55
FILEPATTERN='file-[0-9][0-9].txt.sorted'
DATADIR="."
BASE_REPO_DIR="/var/opt/gitlab/git-data/repositories/@hashed/"

usage() {

  echo "  Usage: $(basename "$0") <command>"
  echo
  echo "  Commands:"
  echo "    get-repos    get all repos from all file servers"
  echo "    dup-dirs     find duplicate dirs in all files created with get-repos (treats .wiki as different dir)"
  echo "    dup-hashes   find duplicate hashes in all files created with get-repos"
  echo
  exit 1

}

[ "$#" -ne 1 ] && usage

get_repos() {
  for i in $(seq -w 1 $NR_FILESERVERS); do
    echo "file-${i}-stor-gprd.c.gitlab-production.internal..."
    ssh -o "StrictHostKeyChecking=no" file-"${i}"-stor-gprd.c.gitlab-production.internal \
      sudo find $BASE_REPO_DIR -type d -mindepth 3 -maxdepth 3 >$DATADIR/file-"${i}".txt
  done
}

sort_files() {
  for i in "$DATADIR"/file-*.txt; do
    echo "sorting $i..."
    sort "$i" >"$DATADIR/$i.sorted"
  done
}

get_unique_hashes() {
  for i in "$DATADIR"/file-*.txt.sorted; do
    echo "getting uniq hashes from $i..."
    cut -d'.' -f1 "$i" | uniq >$DATADIR/"${i}"_hashes
  done
}

find_dups() {

  pattern="$FILEPATTERN"
  [ "$1" ] && pattern="$1"

  FILES=$(
    cd $DATADIR || exit
    echo "$pattern"
    cd - || exit >/dev/null
  )
  echo "Files: $FILES"

  for i in $FILES; do
    for j in $FILES; do

      # we already compared those files
      [ "$j" \< "$i" ] || [ "$j" == "$i" ] && continue

      echo "comparing $i with $j..."

      dups=$(comm -12 --nocheck-order "$i" "$j")

      if [ -n "$dups" ]; then
        echo "$dups" >$DATADIR/dups_"${i}"_"${j}".txt
      fi

    done
  done
}

list_dups() {

  pattern="dups_*_*.sorted.txt"
  [ "$1" ] && pattern="$1"

  FILES=$(
    cd $DATADIR || exit
    echo "$pattern"
    cd - || exit >/dev/null
  )

  for i in $FILES; do
    filea=$(echo "$i" | cut -d'_' -f2 | cut -d'.' -f1)
    # shellcheck disable=SC2001
    fileb=$(echo "$i" | sed 's/dups_file.*\(file-[0-9][0-9]\).*/\1/')
    while read -r line; do
      echo "$line is in $filea and $fileb"
    done <"$i"
  done

}

case $1 in
get-repos)
  get_repos
  ;;

dup-dirs)
  sort_files
  find_dups 'file-[0-9][0-9].txt.sorted'
  list_dups 'dups_*_*.sorted.txt' | sort | tee -a $DATADIR/dup_repos.txt
  ;;

dup-hashes)
  sort_files
  get_unique_hashes
  find_dups 'file-[0-9][0-9].txt.sorted_hashes'
  list_dups 'dups_*_*.sorted_hashes.txt' | sort | tee -a $DATADIR/dup_hashes.txt
  ;;

list-dup-dirs)
  list_dups 'dups_*_*.sorted.txt' | sort | tee $DATADIR/dup_repos.txt
  ;;

list-dup-hashes)
  list_dups 'dups_*_*.sorted_hashes.txt' | sort | tee $DATADIR/dup_hashes.txt
  ;;

*)
  usage
  ;;
esac
