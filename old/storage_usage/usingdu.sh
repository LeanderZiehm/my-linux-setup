du -ah /path/to/search | awk '$1 ~ /[0-9\.]+M/ && $1+0 > 100 {print $2}'
