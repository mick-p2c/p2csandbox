#!/bin/sh 

# required release number (add validity checks)
VER=$1
BRANCH="release/$VER"
# option to skip tests
SKIP_TESTS=$2

REPO="git@github.com:mick-p2c/p2csandbox.git"
#REPO="https://github.com/ospector/sbdemo.git"

BUILD_DIR=`mktemp -d build_XXXXXX`
echo "Working build dir: $BUILD_DIR"
git clone $REPO $BUILD_DIR

#
# BRANCH
#
cd $BUILD_DIR
git ls-remote $REPO > ./tmp_br_list
if [ $? != 0 ]; then
  echo "Cannot fetch remote branches !!!"
  exit 1
fi
grep -q "remotes/origin/$BRANCH" ./tmp_br_list
git checkout $BRANCH
RC=$?
if [ $RC != 0 ]; then
  "New RELEASE  $BRANCH"
  git checkout -b $BRANCH
  git push -u origin $BRANCH
  sed -i "s/development-SNAPSHOT/$VER-SNAPSHOT/"  ./pom.xml
  git add ./pom.xml
  git commit ./pom.xml -m "Auto update version for new Release: $VER"
  git push
fi

#
# BUILD NUM
#
REL=`git tag -l | grep $VER | sort | tail -1 | cut -d\. -f3`
if [ -z $REL ]; then
  REL=0
else
  REL=$((REL+1))
fi

#
# BUILD
#
sed -i "s/$VER-SNAPSHOT/$VER.$REL/"  ./pom.xml
mvn install
if [ $? != 0 ]; then
  echo "BUILD FAILED!!!"
  exit 1
fi

#
# TAG
#
TAG="V$VER.$REL"
echo "NEW BUILD: $TAG"
git tag $TAG $BRANCH
git push origin tag $TAG

exit 0


