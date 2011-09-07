#!/bin/bash

root=http://rjmac.github.com

if [ "x$1" = "x-go" ]; then
    dir="$2"
    cd "$dir"
    cat >index.html <<EOF
<html>
  <head>
    <title>Index of /$dir/</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
  </head>
  <body>
    <h1>Index of /$dir/</h1>

    <table cellspacing="10">
      <tr>
        <th align="left">Name</th>
        <th>Last Modified</th>
        <th>Size</th>
        <th>Description</th>
      </tr>

      <tr>
        <td>
          <a href="../">Parent Directory</a>
        </td>
      </tr> 
EOF
    for f in *; do
        if [ "$f" != "index.html" ]; then
            if [ -d "$f" ]; then
                link="$root/$dir/$f/"
                size="&nbsp;"
            else
                link="$root/$dir/$f"
                size=$(/usr/bin/stat -c %s "$f")
            fi
            lastmodified_epoch=$(/usr/bin/stat -c %Y "$f")
            lastmodified=$(perl -e 'use POSIX; ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime('$lastmodified_epoch'); print strftime("%a %b %d %H:%M:%S GMT %Y", $sec,$min,$hour,$mday,$mon,$year);')
            cat >>index.html <<EOF
                  <tr>
            <td>
                              <a href="$link">$f</a>

                          </td>
            <td>
              $lastmodified
            </td>
            <td align="right">
                              $size
                          </td>
            <td>
              &nbsp;
            </td>
          </tr>
EOF
        fi
    done

cat >>index.html <<EOF
            </table>
  </body>
</html>
EOF
else
    # rsync --progress -ra rojoma.com:nexus/sonatype-work/nexus/storage/ maven
    find maven -name repository-metadata.xml -print0 | xargs -0 sed -i "s!@rootUrl@/content/repositories/!$root/maven/!"
    echo Regenerating index.html...
    find maven -type d -exec "$0" -go '{}' \;
    git add .
    GIT_EDITOR=/bin/true git commit --amend
    git push -f
fi
