# IconBounce

## Dependencies

- theos


## Setup

### theos

```bash
$ cd /usr/local
$ git clone https://github.com/rpetrich/theos.git
$ cd theos
$ ./bin/bootstrap.sh substrate
```

### ldid

```bash
$ wget http://joedj.net/ldid
$ mv ldid ~/bin/
$ chmod +x ~/bin/ldid
```

### dpkg

```bash
$ curl http://debmaker-osx.googlecode.com/svn-history/r5/trunk/dpkg-deb > ~/bin/dpkg-deb
$ chmod +x ~/bin/dpkg-deb
```

### Update theos

```bash
$ rm theos && ln -s $THEOS theos
$ rm iconbouncepreferences/theos && ln -s $THEOS iconbouncepreferences/theos
```
