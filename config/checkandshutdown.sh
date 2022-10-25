#!/bin/bash
filemodified=$(stat -c %y "nohup.out")
modified=$(date -d "$filemodified" "+%s")
current=$(date "+%s")
difference=$(( ($current - $modified) / (60 * 60) ))
if [[ $difference -ge 1 ]]; then
        sudo shutdown -h now
fi