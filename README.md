docker-rpmbuild
===============

A minimal docker rpmbuilder image.

Based on centos, includes only rpmdevtools and yum-utils and a couple
of scripts that automate building RPM packages.

The scripts take care of installing build dependencies (using
yum-builddep), building the package (using rpmbuild) and placing the
resulting RPMs in output directory.

The setup is based on Fedora packaging how-to:
http://fedoraproject.org/wiki/How_to_create_an_RPM_package

Usage
=====

The image expects that work directory will be set to directory
containing the sources (mounted from the host).

Typical usage:

```sh
mkdir -p build/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
cp MYPROJ.spec build/SPECS/
docker run --rm --volume=$PWD/build:/root/rpmbuild \
  rpmbuild MYPROJ.spec
```

This will build the project `MYPROJ` in the `build` directory, placing
results in `RPMS/${ARCH}/` and `SRPMS/` subdirectories under `build`
directory.


If your package requires something from a non-core repo to build, you
can add that repo using a PRE_BUILDDEP hook.  It is an env variable
that should contain an inline script or command to add the repo you
need.  E.g. for EPEL do:

```sh
mkdir -p build/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
cp MYPROJ.spec build/SPECS/
docker run --rm --volume=$PWD/build:/root/rpmbuild \
  --env=PRE_BUILDDEP="yum install -y epel-release" \
  rpmbuild MYPROJ.spec
```

Debugging
=========

There are two options to aid with debugging the build.  One is to set
VERBOSE option in the environment (with `-e VERBOSE=1` option to
`docker run`) which will enable verbose output from the scripts and
rpmbuild.  The other is to pass an `--sh` option to the image, which
will drop to the shell instead of running rpmbuild, e.g.:

```sh
mkdir -p build/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
cp MYPROJ.spec build/SPECS/
docker run -it -e VERBOSE=1 --rm --volume=$PWD/build:/root/rpmbuild \
  rpmbuild --sh MYPROJ.spec
```

From there you can inspect the environment and you can run the build
manually by running `rpmbuild`:

```sh
rpmbuild -ba /root/rpmbuild/SPECS/MYPROJ.spec
```
