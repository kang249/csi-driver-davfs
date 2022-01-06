#!/bin/bash
VERSION="${1}"
[ -z "${VERSION}" ] &&
  echo "You need to pass a semver version string i.e. (1.0.3)!" &&
  exit 1

# update deployment image versions
sed -i 's/kang249\/csi-driver-davfs:v.*/kang249\/csi-driver-davfs:v'"${VERSION}"'/' deploy/kubernetes/csi-attacher-davfsplugin.yaml
sed -i 's/kang249\/csi-driver-davfs:v.*/kang249\/csi-driver-davfs:v'"${VERSION}"'/' deploy/kubernetes/csi-nodeplugin-davfsplugin.yaml

# update binary version
sed -i 's/.*version =.*/	version = "'"${VERSION}"'"/' pkg/davfs/davfs.go

# concat deployment files
rm deploy/kubernetes/all.yaml
cat deploy/kubernetes/*.yaml >> deploy/kubernetes/all.yaml

# git version bump
git add -A
git commit -m "build: ${VERSION}"
git push origin master

# git tag
git push --delete origin "v${VERSION}" || true
git tag -d "v${VERSION}" || true
git tag "v${VERSION}"
git push --tags

# make (make, publish, test, ...)
make all
