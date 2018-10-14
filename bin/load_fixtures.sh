#!/bin/bash
# -*- coding: utf-8 -*-

# 依存関係順に特定の .yml を load する．

dir=test/fixtures
class_list="preferences menus titles products orders"

for class in $class_list; do
	yml=${class}.yml
	echo "- $yml"
	# まず，対象の .yml 以外を .yml.skip にリネームする．
	for old_yml in $(/bin/ls -1 $dir/*.yml 2>/dev/null); do
		if [ $(basename $old_yml) != $yml ]; then
			old_txt=${old_yml}.skip
			mv $old_yml $old_txt
			echo "  $old_yml -> $(basename $old_txt)"
		fi
	done
	# 対象の .yml.skip が存在したら .yml にリネームする．
	txt=$dir/${yml}.skip
	if [ -f $txt ];then
		mv $txt $dir/$yml
		echo "  $txt -> $yml"
	fi
	# .yml だけを load する．
	echo "  Loading fixtures ..."
	bundle exec rails db:fixtures:load
done

echo "- Reverting .yml files ..."
for old_txt in $(/bin/ls -1 test/fixtures/*.yml.skip 2>/dev/null); do
	old_yml=$(dirname $old_txt)/$(basename $old_txt .skip)
	mv $old_txt $old_yml
	echo "  $old_txt -> $(basename $old_yml)"
done

echo "- Done."
ls $dir
