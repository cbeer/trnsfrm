Trnsfrm is a Sinatra-based application for taking an input file (from the filesystem, over http, or ftp) and running transformation scripts on it. Each transformation is represented by a Ruby class (see services/* for example transforms), which take the file and run services over it. The result is persisted to the file system and can be retrieved. All derivative output is represented in an Atom OAI-ORE resource map.

# Usage

Start the Sinatra server:

```bash
$ ruby trnsfrm.rb
```

Use an HTTP POST (or GET) method:

```bash
$ curl http://localhost:8080/transform/identify?location=./Gemfile
```

This page will send a `302 Redirect` to the Atom OAI-ORE resource map at

```bash
$ curl http://localhost:8080/retrieve/e4d9b5574772ddbea446e42fed6ec89a
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<entry xmlns="http://www.w3.org/2005/Atom">
  <id>e4d9b5574772ddbea446e42fed6ec89a</id>
  <link rel="alternate" type="application/octet-stream" href="http://localhost:8080/retrieve/e4d9b5574772ddbea446e42fed6ec89a/ORIGINAL"/>
  <link rel="self" type="application/atom+xml" href="/retrieve/e4d9b5574772ddbea446e42fed6ec89a"/>
  <link rel="http://www.openarchives.org/ore/terms/describes" href="/retrieve/e4d9b5574772ddbea446e42fed6ec89a"/>
  <published>2011-11-21T08:09:14-0500</published>
  <updated>2011-11-20T22:23:27-0500</updated>
  <link rel="http://www.openarchives.org/ore/terms/aggregates" href="http://localhost:8080/retrieve/e4d9b5574772ddbea446e42fed6ec89a/ORIGINAL" title="original" type="application/octet-stream"/>
  <link rel="http://www.openarchives.org/ore/terms/aggregates" href="http://localhost:8080/retrieve/e4d9b5574772ddbea446e42fed6ec89a/identify" title="identify" type="application/octet-stream"/>
</entry>
```

Note the original input file is hashed (using MD5 here). For local
files, the requested file will by symlinked into the pairtree structure.
For HTTP/FTP requests, the file will be retrieved and placed in the Pairtree.
On subsequent requests with the same file, an existing file will be used
instead of re-fetching it. and stored in a Pairtree folder structure with 
a Checkm manifest of all derivative files.

Derivative files may be retrieved by following the links:

```bash
curl http://localhost:8080/retrieve/e4d9b5574772ddbea446e42fed6ec89a/identify
```

```
./ORIGINAL: ASCII text
```

More complex transformations can be implemented, including those that
require extensive background processing (due to long running times,
queueing, etc), one-to-many output, etc.


