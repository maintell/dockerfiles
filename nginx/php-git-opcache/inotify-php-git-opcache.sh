#!/bin/sh


# src=/data/www/
inotifywait -mrq --timefmt '%d/%m/%y %H:%M' --format '%T %w%f%e' -e modify,delete,create,attrib $1 |  while read file
do
      echo "  ${file} inotifywait"
      tag=$(cat $file);
      

      cd $GIT_DIR_ENV;
# adduser -u 1000 -D www


#su  www /bin/bash  -c "git status;git reset --hard;git clean -df;";
su  $GIT_DIR_USER_ENV /bin/sh  -c "git status;git reset --hard;";



su $GIT_DIR_USER_ENV /bin/sh  -c "ssh -T -o StrictHostKeyChecking=no ssh.gogs.lkweixin.com || echo 'ssh确认'";
su $GIT_DIR_USER_ENV /bin/sh  -c "git fetch;";

    
    if [[ -n $(git tag | grep -w "$tag")  ]]; then
       echo '开始更新';
    else
      echo "该标签不存在"
exit;
    fi

if [ -n "$UPDATE_BEFORE_SHELL_STRING"];then
    echo $UPDATE_BEFORE_SHELL_STRING;
    su  $GIT_DIR_USER_ENV /bin/sh  -c $UPDATE_BEFORE_SHELL_STRING;
fi;



echo '当前日志: '$(git log --oneline --decorate|grep tag|head -1)
currentTag=$(git log --oneline --decorate|grep tag|head -1|sed -e 's/.*tag: \([0-9.]*\).*/\1/');
echo '当前标签: '$currentTag
git diff $currentTag $tag --name-only|sed -e 's#\(.*\)#'$(pwd)'/\1#' > /tmp/git_pull_files.log
chmod 777 /tmp/git_pull_files.log;

su $GIT_DIR_USER_ENV /bin/sh  -c "echo '开始更新代码' && git checkout $tag;git status";
echo '更新后日志: '$(git log --oneline --decorate|grep tag|head -1)


cp -f /opcacheUpdate.php $GIT_DIR_USER_ENV/opcacheUpdate.php;
chmod 777 $GIT_DIR_USER_ENV/opcacheUpdate.php;
curl --data-binary "@/tmp/git_pull_files.log" localhost/opcacheUpdate.php;
rm -f $GIT_DIR_USER_ENV/opcacheUpdate.php;


if [ -n "$UPDATE_AFTER_SHELL_STRING"];then
    echo $UPDATE_AFTER_SHELL_STRING;
    su  $GIT_DIR_USER_ENV /bin/sh  -c $UPDATE_AFTER_SHELL_STRING;
fi;


done